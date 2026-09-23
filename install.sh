#!/bin/bash
# Instalador do CodeFy (Mac e Linux). No Mac: clique duas vezes (na primeira vez: botão direito › Abrir).
# No Linux: bash Instalar-CodeFy.command
# Instala o comando "codefy" sem Docker e sem senha de administrador: Node e CodeFy ficam em ~/.codefy.
# codefy = terminal na pasta atual; codefy web = o site (arquivos, chat, terminal) na pasta atual.
set -u
BASE="${CODEFY_BASE:-https://raw.githubusercontent.com/lucasahimself21/codefy-instalador/main}"
CX="$HOME/.codefy"
NODE_DIR="$CX/node"
OS=$(uname -s)

b() { printf '\033[1m%s\033[0m\n' "$*"; }
ok() { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*"; }
fail() { printf '\033[31m✗ %s\033[0m\n' "$*"; echo; read -r -p "Aperte Enter pra fechar." _ </dev/tty; exit 1; }
yes() { local a; read -r -p "$1 [S/n]: " a </dev/tty; [[ ! "$a" =~ ^[nN] ]]; }

clear 2>/dev/null
b "CodeFy: instalação"
echo "Não precisa de Docker nem de senha de administrador. Leva 1 ou 2 minutos."
echo
mkdir -p "$CX"

# ---- 1) Node (o CodeFy roda nele) ----
node_ok() { command -v node >/dev/null 2>&1 && [ "$(node -v | sed 's/^v\([0-9]*\).*/\1/')" -ge 18 ] 2>/dev/null; }
if [ -x "$NODE_DIR/bin/node" ]; then NODE_BIN="$NODE_DIR/bin"; ok "Node.js pronto"
elif node_ok; then NODE_BIN="$(dirname "$(command -v node)")"; ok "Node $(node -v) já instalado"
else
  echo "Baixando o Node.js…"
  case "$(uname -m)" in arm64|aarch64) ARCH=arm64 ;; *) ARCH=x64 ;; esac
  PLAT=$([ "$OS" = Darwin ] && echo darwin || echo linux)
  NAME=$(curl -fsSL -m 60 https://nodejs.org/dist/latest-v22.x/SHASUMS256.txt | grep -o "node-v[0-9.]*-$PLAT-$ARCH\.tar\.gz" | head -1)
  [ -n "$NAME" ] || fail "Não consegui achar o Node.js pra este computador. Confira a internet."
  TMP=$(mktemp -d)
  curl -fL --progress-bar -o "$TMP/node.tgz" "https://nodejs.org/dist/latest-v22.x/$NAME" || fail "Não consegui baixar o Node.js."
  tar xzf "$TMP/node.tgz" -C "$TMP" || fail "O arquivo do Node.js veio estranho."
  rm -rf "$NODE_DIR" && mv "$TMP/${NAME%.tar.gz}" "$NODE_DIR" && rm -rf "$TMP"
  NODE_BIN="$NODE_DIR/bin"
  ok "Node.js pronto"
fi
export PATH="$CX/bin:$NODE_BIN:$PATH"

# ---- 2) CodeFy ----
echo "Baixando o CodeFy…"
rm -f "$CX/bin/codefy" "$CX/bin/claudex" # comando antigo (modo Docker), se tiver
"$NODE_BIN/npm" install -g --prefix "$CX" --no-audit --no-fund --loglevel=error --update-notifier=false "$BASE/codefy-cli.tgz" && [ -x "$CX/bin/codefy" ] \
  || fail "Não consegui instalar o CodeFy. Confira a internet e tente de novo."
ok "CodeFy instalado"

# Põe o comando no PATH (zsh e bash).
LINE='export PATH="$HOME/.codefy/bin:$PATH"'
[ "$NODE_BIN" = "$NODE_DIR/bin" ] && LINE='export PATH="$HOME/.codefy/bin:$HOME/.codefy/node/bin:$PATH"'
for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile"; do
  { [ -f "$rc" ] || [ "$rc" = "$HOME/.zshrc" -a "$OS" = Darwin ] || [ "$rc" = "$HOME/.bashrc" -a "$OS" != Darwin ]; } || continue
  grep -v '\.codefy/bin' "$rc" > "$rc.codefy-tmp" 2>/dev/null; mv "$rc.codefy-tmp" "$rc" 2>/dev/null
  sed -i.bak '/^# CodeFy$/d' "$rc" 2>/dev/null && rm -f "$rc.bak"
  printf '\n# CodeFy\n%s\n' "$LINE" >> "$rc"
done

# ---- 3) Conexão ----
echo
"$CX/bin/codefy" check
[ $? -eq 1 ] && warn "Depois que o admin liberar, é só usar o codefy (não precisa instalar de novo)."

echo
b "CodeFy instalado."
echo "Abra um Terminal novo, entre na pasta do seu projeto e rode:"
echo "  codefy            o CodeFy no terminal"
echo "  codefy web        o CodeFy no navegador (arquivos, chat e terminal)"
echo "Ele avisa quando tiver versão nova."
echo
DEF="$HOME/CodeFy"
yes "Abrir o CodeFy agora no navegador (pasta $DEF)?" && { mkdir -p "$DEF" && cd "$DEF" && exec "$CX/bin/codefy" web </dev/tty; } # </dev/tty: funciona também via curl | bash
