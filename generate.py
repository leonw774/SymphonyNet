import time
from argparse import ArgumentParser
from traceback import format_exc
from fairseq.models import FairseqLanguageModel
from src.fairseq.gen_utils import (
    process_prime_midi,
    gen_one,
    get_trk_ins_map,
    get_note_seq,
    note_seq_to_midi_file,
    music_dict
)

parser = ArgumentParser()
parser.add_argument(
    '--num-output', '-n',
    type=int,
    default=1
)
parser.add_argument(
    '--max-measure-count', '-m',
    type=int,
    default=4
)
parser.add_argument(
    '--min-len',
    type=int,
    default=0
)
parser.add_argument(
    '--max-len', '-l',
    type=int,
    default=4090
)
parser.add_argument(
    '--output-txt', '-t',
    action='store_true'
)
parser.add_argument(
    '--use-cuda',
    action='store_true'
)
parser.add_argument(
    '--primer', '-p',
    metavar='midi_name',
    dest='midi_name',
    type=str,
    default=''
)
parser.add_argument(
    '--primer-list', '-P',
    metavar='midi_name_list',
    dest='midi_name_list',
    type=str,
    default=''
)
parser.add_argument(
    '--output-path', '-o',
    metavar='output_name',
    dest='output_name',
    type=str,
    default='output'
)
parser.add_argument(
    '--checkpoint-path', '-c',
    type=str,
    default=''
)
args = parser.parse_args()
print('\n'.join([f'{k}:{v}' for k, v in vars(args).items()]))
assert args.midi_name == '' or args.midi_name_list == '', 'midi_name and midi_name_list are both given'

MAX_POS_LEN = 4096
PI_LEVEL = 2
IGNORE_META_LOSS = 1
RATIO = 4
BPE = "_bpe" # or ""

DATA_BIN=f"linear_{MAX_POS_LEN}_chord{BPE}_hardloss{IGNORE_META_LOSS}"
DATA_BIN_DIR=f"./data/model_spec/{DATA_BIN}/bin/"
DATA_VOC_DIR=f"./data/model_spec/{DATA_BIN}/vocabs/"
music_dict.load_vocabs_bpe(DATA_VOC_DIR, './data/bpe_res/' if BPE == '_bpe' else None)

if args.checkpoint_path == '':
    checkpoint_path = f'checkpoint_last_{DATA_BIN}_PI{PI_LEVEL}.pt'
else:
    checkpoint_path = args.checkpoint_path

custom_lm = FairseqLanguageModel.from_pretrained('.',
    checkpoint_file=checkpoint_path,
    data_name_or_path=DATA_BIN_DIR,
    user_dir="./src/fairseq/linear_transformer_inference"
)
m = custom_lm.models[0]
if args.use_cuda:
    m.cuda()
m.eval()

max_chord_measure_cnt = 0
if args.midi_name_list != '':
    with open(args.midi_name_list, 'r', encoding='utf8') as primer_paths_file:
        midi_name_list = [p.strip() for p in primer_paths_file.readlines()]
    assert len(midi_name_list) == args.num_output

for n in range(args.num_output):
    start_time = time.time()

    # pprepare prime
    if args.midi_name == '' and args.midi_name_list == '':
        prime = [(2, 2, 2, 1, 0, 0)]
    else:
        try:
            if args.midi_name != '':
                prime, ins_label = process_prime_midi(args.midi_name, args.max_measure_count, max_chord_measure_cnt)
            else:
                prime, ins_label = process_prime_midi(midi_name_list[n], args.max_measure_count, max_chord_measure_cnt)
        except (AssertionError, ValueError) as e:
            print('Fail to process prime midi:', repr(e))
            continue

    try_num = 0
    while try_num < 20:
        try:
            generated, ins_logits = gen_one(m, prime, MAX_LEN=args.max_len, MIN_LEN=args.min_len)
            trk_ins_map = get_trk_ins_map(generated, ins_logits)
            note_seq = get_note_seq(generated, trk_ins_map)
            break
        except AssertionError as e:
            try_num += 1
            print(repr(e))
            # print(format_exc())
            continue
        except Exception as e:
            print(format_exc())
            raise e
    if try_num >= 20:
        continue
    timestamp = time.strftime("%m-%d_%H-%M-%S", time.localtime())
    output_name = f'{args.output_name}_prime{args.max_measure_count}_chord{max_chord_measure_cnt}_{timestamp}.mid'
    note_seq_to_midi_file(note_seq, output_name)
    print('Generated', output_name)
    print('UsedTime', time.time() - start_time)
    if args.output_txt:
        output_name = f'{args.output_name}_prime{args.max_measure_count}_chord{max_chord_measure_cnt}_{timestamp}.txt'
        with open(output_name, 'w+', encoding='utf8') as f:
            f.write('event    duration track_id index    position measure\n')
            f.write(
                '\n'.join([
                    ' '.join([
                        f'{music_dict.index2word(i, x):<8}' if i == 0 else f'{x:<8}'
                        for i, x in enumerate(t)
                    ])
                    for t in generated
                ])
            )
