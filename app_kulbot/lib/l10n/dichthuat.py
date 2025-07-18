import time
from googletrans import Translator
import re
import os

translator = Translator()
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
dich_tu_ngon_ngu = "en"
input_path = os.path.join(BASE_DIR, 'app_en.arb') #không nên thay file này vì tiếng anh là mặc định 
sang_ngon_ngu = "vi" #'vi', 'ja', 'es'
output_path = os.path.join(BASE_DIR, f'app_{sang_ngon_ngu}.arb')

# //////////////////////////////////////////////
# File này dùng để tạo dịch tự động từ input_path sang output_path(tạo hoặc cập nhật file output_path)
# Dịch được rất nhiều ngôn ngữ
# Muốn dịch sang ngôn ngữ gì thì đổi biến sang_ngon_ngu
# Mà cái này nó dịch hơi ngu nên nhớ check lại
# Create By: Kha (tts)
# Cái gì khó có python :))
# //////////////////////////////////////////////

batch_size = 50     # tốc độ dịch (50 dòng/giây + tốc độ phản hồi api) nếu lỗi timeout sẽ dịch từng dòng lâu hơn
delimiter = '\n'

with open(input_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

total = len(lines)
valid_lines = []
for line in lines:
    match = re.match(r'(\s*"[^"]+":\s*)"(.+?)"(,?)', line)
    if match:
        valid_lines.append(line)

total_valid = len(valid_lines)
current_valid = 0

with open(output_path, 'w', encoding='utf-8') as f:
    for i in range(0, total, batch_size):
        batch = lines[i:i+batch_size]
        matches = []
        for line in batch:
            match = re.match(r'(\s*"[^"]+":\s*)"(.+?)"(,?)', line)
            if match:
                matches.append(match.group(2))
            else:
                matches.append(None)

        need_translate = [v for v in matches if v is not None]
        translated_values = []

        if need_translate:
            joined = delimiter.join(need_translate)
            try:
                translated_joined = translator.translate(joined, src=dich_tu_ngon_ngu, dest=sang_ngon_ngu).text
                translated_values = translated_joined.split(delimiter)

                if len(translated_values) != len(need_translate):
                    print(f"Lỗi tách chuỗi tại batch {i}, thử dịch từng dòng.")
                    translated_values = []
                    for v in need_translate:
                        try:
                            translated = translator.translate(v, src='en', dest='vi').text
                        except Exception as e:
                            translated = v
                        translated_values.append(translated)
            except Exception as e:
                print(f"Lỗi khi dịch batch {i}: {e}")
                translated_values = need_translate

        idx_trans = 0
        for idx, line in enumerate(batch):
            match = re.match(r'(\s*"[^"]+":\s*)"(.+?)"(,?)', line)
            if match:
                prefix = match.group(1)
                suffix = '' if current_valid + 1 == total_valid else ','  # ← Không có dấu phẩy nếu là dòng cuối
                translated = translated_values[idx_trans]
                idx_trans += 1
                current_valid += 1
                f.write(f'{prefix}"{translated}"{suffix}\n')
            else:
                f.write(line)
        print(f"✅ Dịch xong dòng {i} đến {min(i+batch_size, total)-1}")
        time.sleep(1)

print("✅ Dịch xong toàn bộ file!")
