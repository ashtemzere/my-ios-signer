#!/bin/bash
# سکریپتی وێنەگیری IPA

echo "🔧 دەستپێکردنی وێنەگیری..."

# دانانی ZSign ئەگەر نییە
if [ ! -d "zsign" ]; then
    git clone https://github.com/zhlynn/zsign.git
    cd zsign
    make
    cd ..
fi

# گەڕان بۆ فایلەکان
IPA_FILE=$(find . -name "*.ipa" -type f | head -1)
P12_FILE=$(find . -name "*.p12" -type f | head -1)
PROV_FILE=$(find . -name "*.mobileprovision" -type f | head -1)

# وەرگرتنی تێپەڕەوشە
if [ -f "config.json" ]; then
    PASSWORD=$(grep -o '"password":"[^"]*"' config.json | cut -d'"' -f4)
else
    read -sp "🔑 تێپەڕەوشەی P12: " PASSWORD
    echo
fi

# پشکنینی فایلەکان
if [ -z "$IPA_FILE" ]; then
    echo "❌ IPA فایل نەدۆزرایەوە"
    exit 1
fi

if [ -z "$P12_FILE" ]; then
    echo "❌ P12 فایل نەدۆزرایەوە"
    exit 1
fi

if [ -z "$PROV_FILE" ]; then
    echo "❌ Provisioning Profile نەدۆزرایەوە"
    exit 1
fi

# وێنەگیری
echo "🔄 وێنەگیری $IPA_FILE..."
./zsign/zsign -k "$P12_FILE" -p "$PASSWORD" -m "$PROV_FILE" -o "signed_$(date +%Y%m%d_%H%M%S).ipa" "$IPA_FILE"

if [ $? -eq 0 ]; then
    echo "✅ وێنەگیری سەرکەوتووبوو!"
    echo "📱 IPA وێنەگیردراو: signed_*.ipa"
else
    echo "❌ هەڵە لە وێنەگیری"
    exit 1
fi
