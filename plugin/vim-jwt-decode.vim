if !has("python3")
  echo "vim-jwt-decode need vim to be compiled with +python3"
  finish
endif

if exists('g:vim_jwt_decode_plugin_loaded')
  finish
endif

nmap <silent><leader>jwt :JwtDecode<CR>

python3 << EOF
import base64
import json
import vim

def jwt_decode():
    row, col = vim.current.window.cursor
    current_line = vim.current.buffer[row-1]

    if not current_line:
        print('Nothing to decode!')
        return

    try:
        header, payload, _ = current_line.split('.')

        vim.current.buffer[:] = (_decode(header)+',').splitlines() +\
            _decode(payload).splitlines()
    except Exception as e:
        print('Failed to decode JWT! (%s)' % (e.msg))
        return

    vim.command('set syntax=on')
    vim.command('set filetype=json')

def _decode(text):
    text = text + '==' # add extra padding
    decoded = base64.b64decode(text.encode('ascii')).decode('ascii')
    pretty = json.dumps(json.loads(decoded), indent=2)
    return pretty
EOF

function! JwtDecode()
    python3 jwt_decode()
endfunction

command! -nargs=0 JwtDecode call JwtDecode()

let g:vim_jwt_decode_plugin_loaded = 1
