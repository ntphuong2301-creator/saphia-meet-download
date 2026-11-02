#!/usr/bin/env bash
# Phát hành Saphia Meet bản mới lên kho này. Link cho team KHÔNG đổi.
# Dùng: tools/phat-hanh.sh <phiên bản> <bộ cài đầy đủ .exe> <bản cập nhật nhỏ .exe>
set -euo pipefail
V="$1"; FULL="$2"; PATCH="$3"
cd "$(dirname "$0")/.."
G="git -c user.name=Saphia_Meet -c user.email=ntphuong2301@gmail.com"
git pull -q --ff-only origin main || true
mkdir -p "payload/$V"
split -b 45m -d -a 1 "$FULL" "payload/$V/part"
PARTS=$(ls "payload/$V" | sort | sed "s#^#payload/$V/#" | paste -sd, -)
# đẩy từng phần một (proxy giới hạn kích thước mỗi lần đẩy)
for p in $(echo "$PARTS" | tr ',' ' '); do $G add "$p"; $G commit -qm "$V: $(basename "$p")"; git push -q origin HEAD:main; done
cp "$PATCH" SaphiaMeet-CapNhat.exe
printf 'version=%s\nsha256=%s\nparts=%s\n' "$V" "$(sha256sum "$FULL" | cut -d' ' -f1)" "$PARTS" > latest.txt
# giữ 2 bản gần nhất trong payload, xóa bản cũ hơn
ls -d payload/*/ | sort -V | head -n -2 | xargs -r git rm -rq
$G add -A latest.txt SaphiaMeet-CapNhat.exe payload; $G commit -qm "Phát hành Saphia Meet $V"; git push -q origin HEAD:main
echo "Xong. Link cho team (không đổi): https://github.com/ntphuong2301-creator/saphia-meet-download/raw/main/SaphiaMeet-CaiDat.exe"
