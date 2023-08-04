import sys

assert len(sys.argv) == 2
log_path = sys.argv[1]
with open(log_path, 'r', encoding='utf8') as log_file:
    usedtime_lines = [
        l.strip().split()[1]
        for l in log_file.readlines()
        if l.startswith('UsedTime')
    ]
total_used_time = sum(
    map(float, usedtime_lines)
)
result_str = f'Generation takes {total_used_time} seconds\n'
print(result_str)
with open(log_path, 'w+', encoding='utf8') as log_file:
    log_file.write(result_str)
