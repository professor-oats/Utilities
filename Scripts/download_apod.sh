#!/bin/bash
# NASA APOD Archive Downloader
# Downloads all "Picture of the Day" images from apod.nasa.gov

# Config
BASE_URL="https://apod.nasa.gov/apod"
OUTPUT_DIR="./nasa_apod_images"
START_DATE=${1:-19950601}
END_DATE=${2:-$(date +%Y%m%d)}
MAX_IMAGES=${3:-0}

mkdir -p "$OUTPUT_DIR"

DOWNLOADED=0
SKIPPED=0
FAILED=0

echo "=== NASA APOD Archive Downloader ==="
echo "Date range: $START_DATE to $END_DATE"
echo "Max images: $MAX_IMAGES (0 = unlimited)"
echo "Output: $(realpath "$OUTPUT_DIR")"
echo ""

# Fetch archive and extract date codes
echo "Fetching archive..."
ARCHIVE_HTML=$(curl -s -L "$BASE_URL/archivepixFull.html")

DATE_CODES=$(echo "$ARCHIVE_HTML" | \
    grep -oE 'ap[0-9]{6}\.html' | \
    sed 's/ap//; s/\.html//' | \
    sort -r)

if [[ -z "$DATE_CODES" ]]; then
    echo "ERROR: No dates found"
    exit 1
fi

echo "Found $(echo "$DATE_CODES" | wc -l) date entries"
echo ""

for DATE_CODE in $DATE_CODES; do
    # Check limit
    if [[ $MAX_IMAGES -gt 0 && $DOWNLOADED -ge $MAX_IMAGES ]]; then
        echo ""
        echo "=== Limit reached: $DOWNLOADED images ==="
        break
    fi
    
    # Parse and convert date
    YY="${DATE_CODE:0:2}"
    MM="${DATE_CODE:2:2}"
    DD="${DATE_CODE:4:2}"
    
    if [[ $((10#$YY)) -lt 50 ]]; then
        FULL_DATE="20${YY}${MM}${DD}"
    else
        FULL_DATE="19${YY}${MM}${DD}"
    fi
    
    # Skip if outside range
    if [[ "$FULL_DATE" < "$START_DATE" ]] || [[ "$FULL_DATE" > "$END_DATE" ]]; then
        continue
    fi
    
    # Fetch date page
    DATE_FILE="ap${DATE_CODE}.html"
    DATE_URL="${BASE_URL}/${DATE_FILE}"
    
    echo -n "[$DATE_CODE] "
    
    DATE_HTML=$(curl -s -L "$DATE_URL" 2>/dev/null)
    if [[ $? -ne 0 ]] || [[ -z "$DATE_HTML" ]]; then
        echo "✗ fetch failed"
        ((FAILED++)) || true
        sleep 1
        continue
    fi
    
    # Extract image URL
    IMAGE_PATH=$(echo "$DATE_HTML" | \
        grep -oiE 'image/[^"<> ]+\.(jpg|jpeg|png|gif)' | \
        grep -v '1024' | \
        head -1)
    
    if [[ -z "$IMAGE_PATH" ]]; then
        IMAGE_PATH=$(echo "$DATE_HTML" | \
            grep -oiE 'image/[^"<> ]+\.(jpg|jpeg|png|gif)' | \
            head -1)
    fi
    
    if [[ -z "$IMAGE_PATH" ]]; then
        echo "✗ no image"
        ((FAILED++)) || true
        sleep 1
        continue
    fi
    
    IMAGE_URL="${BASE_URL}/${IMAGE_PATH}"
    FILENAME="${DATE_CODE}_$(basename "$IMAGE_PATH")"
    OUTPUT_FILE="${OUTPUT_DIR}/${FILENAME}"
    
    # Download
    if [[ -f "$OUTPUT_FILE" ]]; then
        ((SKIPPED++)) || true
        echo "skip (exists)"
        sleep 1
        continue
    fi
    
    echo -n "download... "
    if curl -s -L -o "$OUTPUT_FILE" "$IMAGE_URL"; then
        SIZE=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || echo "?")
        echo "✓ (${SIZE} bytes)"
        ((DOWNLOADED++)) || true
    else
        echo "✗ failed"
        ((FAILED++)) || true
        rm -f "$OUTPUT_FILE" 2>/dev/null || true
    fi
    
    sleep 1
done

echo ""
echo "=== Summary ==="
echo "Downloaded: $DOWNLOADED"
echo "Skipped: $SKIPPED"
echo "Failed: $FAILED"
echo "Total: $(find "$OUTPUT_DIR" -type f | wc -l) files"
