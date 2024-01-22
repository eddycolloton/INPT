#!/bin/bash

function remove_special_chars {
    local str=$1
    local accented_chars='éèêëàáâäãåæçèéêëìíîïðñòóôõöùúûüýÿ'
    str=$(printf '%s' "$str" | LC_ALL=C sed -E "s/[^[:print:]\n\r\t$accented_chars]//g")
    str="${str#"${str%%[![:space:]]*}"}"   # Remove leading whitespace
    str="${str%"${str##*[![:space:]]}"}"   # Remove trailing whitespace
    str="${str//[\"]}"
    echo "${str//[\']}"
}

key="Text! with, some@ special characters$ é, è, ê, ü, ñ,€ (Euro), £ (Pound Sterling), ¥ (Yen) and quotes: \"quoted text\" and 'quoted text'"
echo "$key"
key=$(remove_special_chars "$key")
echo "$key"
