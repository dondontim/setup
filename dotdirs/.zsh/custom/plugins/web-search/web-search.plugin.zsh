# How to escape double quotes for google searching with web-search
# Encode $url variable (only query part and output to console)
#
# * google bytes to string \"python\"
# * google bytes to string '"python"'
function special_help_function() 
{
url=$1
# urllib.parse.urlparse()
# 
# scheme://netloc/path;params?query#fragment
#
# Example strings to test
# 'http://www.cwi.nl:80/%7Eguido/Python.html'
# 'http://stack.com/questions/123/blah.php?siema=12&kurwa=siema'
# 
# ParseResult(
#   scheme='http', 
#   netloc='www.cwi.nl:80', 
#   path='/%7Eguido/Python.html',
#   params='', 
#   query='', 
#   fragment=''
# )


python3 <<EOF
import urllib.parse
parsed_uri = urllib.parse.urlparse('$url')

# encode query part of $url
query = urllib.parse.quote_plus(parsed_uri.query)

result = '{uri.scheme}://{uri.netloc}{uri.path}?{q}'.format(uri=parsed_uri, q=query)

# Replace %3D with = and %2B with +
result = result.replace("%3D", "=").replace("%2B", "+")

print(result)
EOF
}





# web_search from terminal
function web_search() {
  emulate -L zsh

  # define search engine URLS
  typeset -A urls
  urls=(
    $ZSH_WEB_SEARCH_ENGINES
    google      "https://www.google.com/search?q="
    bing        "https://www.bing.com/search?q="
    yahoo       "https://search.yahoo.com/search?p="
    duckduckgo  "https://www.duckduckgo.com/?q="
    startpage   "https://www.startpage.com/do/search?q="
    yandex      "https://yandex.ru/yandsearch?text="
    github      "https://github.com/search?q="
    baidu       "https://www.baidu.com/s?wd="
    ecosia      "https://www.ecosia.org/search?q="
    goodreads   "https://www.goodreads.com/search?q="
    qwant       "https://www.qwant.com/?q="
    givero      "https://www.givero.com/search?q="
    stackoverflow  "https://stackoverflow.com/search?q="
    wolframalpha   "https://www.wolframalpha.com/input/?i="
    archive     "https://web.archive.org/web/*/"
    scholar        "https://scholar.google.com/scholar?q="
  )

  # check whether the search engine is supported
  if [[ -z "$urls[$1]" ]]; then
    echo "Search engine '$1' not supported."
    return 1
  fi

  # search or go to main page depending on number of arguments passed
  if [[ $# -gt 1 ]]; then
    # build search url:
    # join arguments passed with '+', then append to search engine URL
    url="${urls[$1]}${(j:+:)@[2,-1]}"

    # Assign value of our helper encoding function
    url=$(special_help_function "$url")
  else
    # build main page url:
    # split by '/', then rejoin protocol (1) and domain (2) parts with '//'
    url="${(j://:)${(s:/:)urls[$1]}[1,2]}"
  fi


  # This will set date range from: Jan 1, 1 BC (Before Christ) - Today
  # and thanks to this it will display publication date next to URL
  url="${url}&tbs=cdr:1,cd_min:1/1/0"


  # try catch shell example
  #
  { # try
    echo "Searching: $url"
    open_command "$url"
  } || { # catch
    echo "Unrecognized search term!"
    echo "url = $url"
  }
}


alias bing='web_search bing'
alias google='web_search google'
alias yahoo='web_search yahoo'
alias ddg='web_search duckduckgo'
alias sp='web_search startpage'
alias yandex='web_search yandex'
alias github='web_search github'
alias baidu='web_search baidu'
alias ecosia='web_search ecosia'
alias goodreads='web_search goodreads'
alias qwant='web_search qwant'
alias givero='web_search givero'
alias stackoverflow='web_search stackoverflow'
alias wolframalpha='web_search wolframalpha'
alias archive='web_search archive'
alias scholar='web_search scholar'

#add your own !bang searches here
alias wiki='web_search duckduckgo \!w'
alias news='web_search duckduckgo \!n'
alias youtube='web_search duckduckgo \!yt'
alias map='web_search duckduckgo \!m'
alias image='web_search duckduckgo \!i'
alias ducky='web_search duckduckgo \!'

# other search engine aliases
if [[ ${#ZSH_WEB_SEARCH_ENGINES} -gt 0 ]]; then
  typeset -A engines
  engines=($ZSH_WEB_SEARCH_ENGINES)
  for key in ${(k)engines}; do
    alias "$key"="web_search $key"
  done
  unset engines key
fi
