#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Read model alias directly from settings file
settings_file="$HOME/.claude/settings.json"
if [ -f "$settings_file" ]; then
    model_name=$(jq -r '.model // "unknown"' "$settings_file")
else
    model_name="unknown"
fi

# Extract current directory from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Get just the directory name (like \W in PS1)
dir_name=$(basename "$cwd")

# Check if we're in a git repository and get branch
git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        # Enhanced git branch with magenta icon and bright green branch name
        git_info=$(printf "\033[35m \033[0m\033[1;92m%s\033[0m " "$branch")
    fi
fi

# Calculate context window usage and build colorful progress bar
context_info=""
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ]; then
    # Calculate percentage
    current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    size=$(echo "$input" | jq '.context_window.context_window_size')
    pct=$((current * 100 / size))

    # Build colorful gradient progress bar (20 characters wide)
    bar_width=20
    filled=$((pct * bar_width / 100))
    empty=$((bar_width - filled))

    # Create the bar with gradient colors based on ranges
    bar=""
    for ((i=0; i<filled; i++)); do
        # Calculate which segment of the bar we're in (0-100)
        segment_pct=$((i * 100 / bar_width))

        if [ $segment_pct -ge 90 ]; then
            # Red zone (90-100%)
            bar="${bar}\033[91m█\033[0m"
        elif [ $segment_pct -ge 75 ]; then
            # Orange/Yellow zone (75-90%)
            bar="${bar}\033[93m█\033[0m"
        elif [ $segment_pct -ge 50 ]; then
            # Yellow zone (50-75%)
            bar="${bar}\033[33m█\033[0m"
        elif [ $segment_pct -ge 25 ]; then
            # Cyan zone (25-50%)
            bar="${bar}\033[96m█\033[0m"
        else
            # Green zone (0-25%)
            bar="${bar}\033[92m█\033[0m"
        fi
    done

    # Add empty segments in dark gray
    for ((i=0; i<empty; i++)); do
        bar="${bar}\033[90m░\033[0m"
    done

    # Color the percentage text based on usage level with more granular ranges
    if [ $pct -ge 95 ]; then
        # Bright red + bold for critical (95%+)
        pct_color="\033[1;91m"
    elif [ $pct -ge 90 ]; then
        # Red for very high (90-95%)
        pct_color="\033[91m"
    elif [ $pct -ge 75 ]; then
        # Yellow for high (75-90%)
        pct_color="\033[93m"
    elif [ $pct -ge 50 ]; then
        # Cyan for medium (50-75%)
        pct_color="\033[96m"
    elif [ $pct -ge 25 ]; then
        # Green for low (25-50%)
        pct_color="\033[92m"
    else
        # Bright green for very low (0-25%)
        pct_color="\033[1;92m"
    fi

    # Format with bright magenta brackets and colorful bar
    context_info=$(printf "\033[95m[\033[0m%b\033[95m]\033[0m %b%3d%%\033[0m " "$bar" "$pct_color" "$pct")
fi

# Build the status line with model name in bright magenta at the start
# Format: [Model] directory branch [progress] percentage
printf "\033[1;95m[%s]\033[0m \033[94m%s\033[0m %s%s" "$model_name" "$dir_name" "$git_info" "$context_info"
