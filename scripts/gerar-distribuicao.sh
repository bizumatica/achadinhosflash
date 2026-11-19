#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Uso: $0 content/ofertas/<slug>"
  exit 1
fi

OFERTA_DIR="${1%/}"
MD_FILE="$OFERTA_DIR/index.md"
WEBP_FILE="$OFERTA_DIR/feature.webp"
SLUG="$(basename "$OFERTA_DIR")"
OUT_IMG="tmp/social/${SLUG}.png"

if [[ ! -f "$MD_FILE" ]]; then
  echo "❌ Erro: Arquivo '$MD_FILE' não encontrado." >&2
  exit 1
fi

# 1. Converte feature.webp para PNG em tmp/social/ (compatível com IG, TikTok e Pinterest no Buffer)
mkdir -p tmp/social
if [[ -f "$WEBP_FILE" ]]; then
  if command -v dwebp >/dev/null 2>&1; then
    dwebp "$WEBP_FILE" -o "$OUT_IMG" >/dev/null 2>&1
    echo "📸 Imagem pronta para upload no Buffer: $OUT_IMG"
  else
    echo "⚠️ Aviso: 'dwebp' não instalado. Instale o pacote 'webp' para converter a imagem automaticamente." >&2
  fi
else
  echo "⚠️ Aviso: '$WEBP_FILE' não encontrado nesta oferta." >&2
fi

# 2. Extrai metadados do Front Matter e gera os templates por canal
python3 - "$MD_FILE" "$SLUG" << 'PYEOF'
import sys, re

md_path, slug = sys.argv[1], sys.argv[2]
with open(md_path, "r", encoding="utf-8") as f:
    content = f.read()

fm_match = re.match(r'^---\s*\n(.*?)\n---', content, re.S)
if not fm_match:
    sys.exit("❌ Erro: Front Matter YAML não encontrado no index.md.")

fm = fm_match.group(1)

def get_val(key):
    m = re.search(rf'^{key}:\s*(.+)$', fm, re.M)
    if not m:
        return ""
    v = m.group(1).strip()
    if (v.startswith('"') and v.endswith('"')) or (v.startswith("'") and v.endswith("'")):
        v = v[1:-1]
    return v.strip()

title = get_val("title")
p_de = get_val("preco_de")
p_por = get_val("preco_por")
cupom = get_val("cupom")

if not title or not p_por:
    sys.exit("❌ Erro: Campos obrigatórios 'title' ou 'preco_por' ausentes no Front Matter.")

stores_raw = get_val("stores")
loja_m = re.search(r'"([^"]+)"|\'([^\']+)\'|\[([^\]]+)\]', stores_raw)
loja = next((g for g in loja_m.groups() if g), "Loja Oficial") if loja_m else "Loja Oficial"
loja_tag = re.sub(r'[^a-zA-Z0-9]', '', loja).lower()

url_base = f"[https://achadinhosflash.net.br/ofertas/](https://achadinhosflash.net.br/ofertas/){slug}/"
sep = "=" * 56

# --- BLOCO 1: BUFFER (INSTAGRAM & TIKTOK) ---
print(f"\n{sep}")
print("1. BUFFER -> INSTAGRAM & TIKTOK (Legenda)")
print(sep)
de_ig = f"De {p_de} por " if p_de else "Por apenas "
cupom_ig = f"\n🎟️ Cupom: {cupom}" if cupom else ""
print(
    f"⚡ ACHADINHO VERIFICADO: {title}\n\n"
    f"💰 {de_ig}{p_por} na {loja}!{cupom_ig}\n\n"
    f"🔗 Link direto no perfil (Bio) ou busque por \"{title}\" em achadinhosflash.net.br\n\n"
    f"#achadinhos #promocao #ofertas #desconto #garimpo #{loja_tag}"
)

# --- BLOCO 2: BUFFER (PINTEREST) ---
print(f"\n{sep}")
print("2. BUFFER -> PINTEREST (Campos Separados)")
print(sep)
print(f"Título: {title} por {p_por} ({loja})")
print(
    f"Descrição: Oferta verificada: {title} na {loja}. "
    f"{de_ig}{p_por}.{f' Use o cupom {cupom}.' if cupom else ''} "
    f"Acesse para conferir os detalhes e aproveitar."
)
print(f"Link de Destino: {url_base}?utm_source=pinterest&utm_medium=social")

# --- BLOCO 3: CANAL WHATSAPP ---
print(f"\n{sep}")
print("3. CANAL WHATSAPP (*negrito* e ~tachado~ nativos)")
print(sep)
wa_lines = [f"⚡ *{title}*", f"🏪 Loja: {loja}"]
if p_de:
    wa_lines.append(f"💸 De: ~{p_de}~")
wa_lines.append(f"🔥 *Por: {p_por}*")
if cupom:
    wa_lines.append(f"🎟️ Cupom: *{cupom}*")
wa_lines.append(f"\n👉 Pegar oferta:\n{url_base}?utm_source=whatsapp&utm_medium=channel")
print("\n".join(wa_lines))

# --- BLOCO 4: CANAL TELEGRAM ---
print(f"\n{sep}")
print("4. CANAL TELEGRAM (Texto limpo sem quebra de Markdown)")
print(sep)
tg_lines = [f"⚡ {title}", f"🏪 Loja: {loja}"]
if p_de:
    tg_lines.append(f"💸 De: {p_de}")
tg_lines.append(f"🔥 Por: {p_por}")
if cupom:
    tg_lines.append(f"🎟️ Cupom: {cupom}")
tg_lines.append(f"\n👉 Acessar oferta:\n{url_base}?utm_source=telegram&utm_medium=channel")
print("\n".join(tg_lines))
print(f"{sep}\n")
PYEOF
