---
# ==============================================================================
# GUIA RÁPIDO DE PREENCHIMENTO (ACHADINHOS FLASH)
# ==============================================================================
# 1. Este arquivo é um Leaf Bundle: salve a foto do produto na mesma pasta
#    com o nome 'feature.webp' (ou .jpg / .png).
# 2. Preencha os metadados abaixo. O shortcode {{< ficha-oferta >}} lerá
#    automaticamente os preços, loja, link e cupom (se houver).
# 3. Se não houver cupom, deixe 'cupom: ""' — o bloco ficará oculto no site.
# 4. Altere 'draft: false' para publicar a oferta.
# ==============================================================================

title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: true
description: "Garimpo verificado: confira detalhes, condições e o link direto para a oferta de {{ replace .Name "-" " " | title }}."

# Taxonomias (mantenha o padrão do portal para agrupar corretamente nas vitrines)
categories: ["Geral"]
# Redes: "Amazon", "Mercado Livre", "Shopee", "AliExpress", "Magalu", "Awin"
stores: ["Amazon"]
tags: ["garimpo", "achadinhos"]

# Dados lidos pelo shortcode {{< ficha-oferta >}}
preco_de: ""
preco_por: "R$ 0,00"
cupom: ""
link_afiliado: "https://"
---

{{< lead >}}
Resumo editorial em uma frase direta: destaque o principal benefício deste produto e por que este preço chamou a atenção da nossa curadoria.
{{< /lead >}}

{{< ficha-oferta >}}

### Por que vale o garimpo?

* **Custo-benefício:** Explique em 1 linha o diferencial técnico ou de preço frente aos concorrentes.
* **Condições de compra:** Informe se há frete grátis, envio rápido (Prime / Full / Oficial) ou parcelamento sem juros.
* **Ponto de atenção:** Registre qualquer detalhe importante antes da compra (voltagem 110V/220V, dimensões, compatibilidade ou cor selecionada).

### Como funciona o redirecionamento

1. Clique no botão **Conferir Oferta** acima para abrir a página oficial do produto na loja parceira.
2. Caso a oferta conte com cupom ativo exibido na ficha, copie o código e aplique-o no carrinho antes de finalizar o pagamento.
3. Conclua a compra diretamente no ambiente seguro da loja varejista.