#!/bin/bash
# Test script for Dairify backup system

echo "🧪 Testing Dairify Backup System"
echo "=================================="
echo ""

# Check if databackup folder exists
BACKUP_DIR="$HOME/.local/share/dairify/databackup"

echo "📁 Checking backup directory..."
if [ -d "$BACKUP_DIR" ]; then
    echo "✅ Backup directory exists: $BACKUP_DIR"
    
    # List backup files
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.json 2>/dev/null | wc -l)
    echo "📊 Total backups: $BACKUP_COUNT"
    
    if [ $BACKUP_COUNT -gt 0 ]; then
        echo ""
        echo "📋 Backup files:"
        ls -lh "$BACKUP_DIR"/*.json
        
        echo ""
        echo "📦 Latest backup:"
        LATEST=$(ls -t "$BACKUP_DIR"/*.json | head -1)
        echo "   File: $(basename $LATEST)"
        echo "   Size: $(du -h $LATEST | cut -f1)"
        echo "   Date: $(stat -c %y $LATEST)"
        
        # Show backup content preview
        echo ""
        echo "🔍 Backup content preview:"
        if command -v jq &> /dev/null; then
            cat $LATEST | jq '.backup_info'
        else
            head -20 $LATEST
        fi
    fi
else
    echo "⚠️  Backup directory not created yet"
    echo "   Directory will be created on first backup"
    echo "   Expected location: $BACKUP_DIR"
fi

echo ""
echo "=================================="
echo "✅ Backup system test complete!"
echo ""
echo "💡 Usage:"
echo "   - Open Dairify app"
echo "   - Go to Settings → Data Backup"
echo "   - Tap 'Create Backup' button"
echo "   - Check this script again to see backups"
