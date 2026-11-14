#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

readonly BASE_DIR="content/ofertas"
TEMP_DIR=""

cleanup() {
  local exit_code=$?
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
  if [[ $exit_code -ne 0 ]]; then
    echo "❌ Operação cancelada ou falhou (código: $exit_code). Nenhum arquivo parcial foi mantido." >&2
  fi
}
trap cleanup EXIT

# Verifica dependências essenciais
for cmd in curl python3 file; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "❌ Dependência ausente: '$cmd'. Instale-a antes de continuar." >&2
    exit 1
  fi
done

# Garante execução na raiz do projeto Hugo
if [[ ! -d "config/_default" || ! -d "content" ]]; then
  echo "❌ Execute este script a partir da raiz do projeto Achadinhos Flash." >&2
  exit 1
fi

# Funções auxiliares de sanitização e validação
slugify() {
  python3 -c '
import sys, unicodedata, re
text = unicodedata.normalize("NFKD", sys.argv[1]).encode("ascii", "ignore").decode("ascii")
text = re.sub(r"[^a-zA-Z0-9]+", "-", text).strip("-").lower()
print(text)
' "$1"
}

escape_yaml() {
  # Escapa barras invertidas e aspas duplas para integridade estrita do Front Matter
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

require_non_empty() {
  local label="$1"
  local value="$2"
  if [[ -z "${value// /}" ]]; then
    echo "❌ O campo '$label' é obrigatório." >&2
    exit 1
  fi
}

echo "=== ⚡ Nova Oferta — Achadinhos Flash ==="

read -rp "1. Título do produto: " TITULO
require_non_empty "Título" "$TITULO"

SLUG=$(slugify "$TITULO")
if [[ -z "$SLUG" ]]; then
  echo "❌ Não foi possível gerar um slug válido a partir do título." >&2
  exit 1
fi

DEST_DIR="$BASE_DIR/$SLUG"
if [[ -e "$DEST_DIR" ]]; then
  echo "❌ Já existe uma oferta publicada em '$DEST_DIR'." >&2
  exit 1
fi

echo "Lojas sugeridas: Amazon | Mercado Livre | Shopee | AliExpress | Magalu | Awin"
read -rp "2. Loja parceira: " LOJA
require_non_empty "Loja" "$LOJA"

read -rp "3. Categoria (padrão: Geral): " CATEGORIA
CATEGORIA="${CATEGORIA:-Geral}"

read -rp "4. Preço De (opcional, ex: R$ 299,90): " PRECO_DE
read -rp "5. Preço Por (obrigatório, ex: R$ 199,90): " PRECO_POR
require_non_empty "Preço Por" "$PRECO_POR"

read -rp "6. Cupom (opcional, Enter para pular): " CUPOM

read -rp "7. Link de afiliado (https://...): " LINK
require_non_empty "Link de afiliado" "$LINK"
if [[ ! "$LINK" =~ ^https?:// ]]; then
  echo "❌ O link de afiliado deve começar com http:// ou https://." >&2
  exit 1
fi

read -rp "8. URL da imagem ou caminho local: " IMAGEM_SRC
require_non_empty "Imagem" "$IMAGEM_SRC"

# Criação atômica em diretório temporário
TEMP_DIR=$(mktemp -d)
RAW_IMG="$TEMP_DIR/raw_image"

echo "==> Processando imagem..."
if [[ "$IMAGEM_SRC" =~ ^https?:// ]]; then
  curl -fsSL \
    -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36" \
    --max-time 20 \
    "$IMAGEM_SRC" -o "$RAW_IMG"
else
  if [[ ! -f "$IMAGEM_SRC" ]]; then
    echo "❌ Arquivo local não encontrado: '$IMAGEM_SRC'." >&2
    exit 1
  fi
  cp "$IMAGEM_SRC" "$RAW_IMG"
fi

# Detecta o MIME type real do arquivo baixado/copiado
MIME_TYPE=$(file --mime-type -b "$RAW_IMG")
EXT=""
case "$MIME_TYPE" in
  image/jpeg) EXT="jpg" ;;
  image/png)  EXT="png" ;;
  image/webp) EXT="webp" ;;
  *)
    echo "❌ Arquivo inválido ou bloqueado pelo servidor (MIME detectado: $MIME_TYPE). Use JPG, PNG ou WebP." >&2
    exit 1
    ;;
esac

FINAL_IMG="$TEMP_DIR/feature.$EXT"
mv "$RAW_IMG" "$FINAL_IMG"

# Converte para WebP otimizado caso ImageMagick/cwebp esteja disponível (preservando qualidade e reduzindo peso)
if [[ "$EXT" != "webp" ]]; then
  if command -v cwebp >/dev/null 2>&1; then
    if cwebp -q 85 "$FINAL_IMG" -o "$TEMP_DIR/feature.webp" >/dev/null 2>&1; then
      rm -f "$FINAL_IMG"
      FINAL_IMG="$TEMP_DIR/feature.webp"
    fi
  elif command -v magick >/dev/null 2>&1; then
    if magick "$FINAL_IMG" -quality 85 "$TEMP_DIR/feature.webp" >/dev/null 2>&1; then
      rm -f "$FINAL_IMG"
      FINAL_IMG="$TEMP_DIR/feature.webp"
    fi
  fi
fi

# Sanitiza campos para YAML
SAFE_TITULO=$(escape_yaml "$TITULO")
SAFE_LOJA=$(escape_yaml "$LOJA")
SAFE_CATEGORIA=$(escape_yaml "$CATEGORIA")
SAFE_PRECO_DE=$(escape_yaml "$PRECO_DE")
SAFE_PRECO_POR=$(escape_yaml "$PRECO_POR")
SAFE_CUPOM=$(escape_yaml "$CUPOM")
SAFE_LINK=$(escape_yaml "$LINK")
ISO_DATE=$(date -Iseconds)

cat << EOF > "$TEMP_DIR/index.md"
---
title: "$SAFE_TITULO"
date: $ISO_DATE
draft: false
description: "Garimpo verificado na $SAFE_LOJA: $SAFE_TITULO por $SAFE_PRECO_POR."
categories: ["$SAFE_CATEGORIA"]
stores: ["$SAFE_LOJA"]
tags: ["garimpo", "achadinhos"]
preco_de: "$SAFE_PRECO_DE"
preco_por: "$SAFE_PRECO_POR"
cupom: "$SAFE_CUPOM"
link_afiliado: "$SAFE_LINK"
---

{{< ficha-oferta >}}

### Por que vale o garimpo?

* **Custo-benefício:** Destaque principal do produto frente aos concorrentes.
* **Condições:** Informação sobre frete, parcelamento ou envio rápido.
* **Ponto de atenção:** Observação honesta de curadoria (voltagem, tamanho ou compatibilidade).
EOF

# Move o bundle completo e validado para o destino final de forma atômica
mkdir -p "$BASE_DIR"
mv "$TEMP_DIR" "$DEST_DIR"
TEMP_DIR=""

echo "✅ Oferta publicada com sucesso em: $DEST_DIR/"
ls -lh "$DEST_DIR"