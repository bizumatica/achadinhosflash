# ⚡ Achadinhos Flash

![Status](https://img.shields.io/badge/status-pré--lançamento-f59e0b?style=flat-square)
![Hugo](https://img.shields.io/badge/hugo-v0.167%2B%20extended-ff4088?logo=hugo&logoColor=white&style=flat-square)
![Theme](https://img.shields.io/badge/tema-Blowfish%20(Modules)-3b82f6?style=flat-square)
![Build](https://img.shields.io/badge/build---panicOnWarning-16a34a?style=flat-square)
![Deploy](https://img.shields.io/badge/target-Cloudflare%20Pages-f38020?logo=cloudflarepages&logoColor=white&style=flat-square)
![License](https://img.shields.io/badge/license-MIT-8532D3?logo=creativecommons&logoColor=white&style=flat-square)

> Portal estático de alta performance dedicado à curadoria editorial de promoções relâmpago, verificação de histórico de preços e achadinhos nas maiores lojas online.

O **Achadinhos Flash** (`achadinhosflash.net.br`) opera sob arquitetura **zero-backend** sobre **Hugo (Extended)** e **Blowfish**, combinando otimização automática de mídia em **WebP**, conformidade legal (**LGPD** e *Affiliate Disclosure*) e publicação atômica via CLI.

---

## 🛠️ Arquitetura & Mapa do Projeto

| Camada | Caminho / Ferramenta | Responsabilidade |
| :--- | :--- | :--- |
| **Core & Módulos** | `config/_default/hugo.toml` | Configuração base, taxonomias (`stores`, `categories`) e `module.mounts` seletivos do Blowfish |
| **Navegação** | `config/_default/menus.pt-br.toml` | Cabeçalho principal e links institucionais/sociais do rodapé |
| **Ofertas (Bundles)** | `content/ofertas/<slug>/` | *Leaf Bundles* autocontidos (`index.md` + `feature.webp` processada via Hugo Pipes) |
| **Compliance** | `content/{sobre,privacidade,termos}.md` | Transparência editorial, LGPD, política de cookies e cláusulas obrigatórias de afiliados |
| **UI & Interatividade** | `layouts/` | Shortcode `ficha-oferta`, página `404.html` inteligente, rodapé customizado e botão *Copiar Link* |
| **Automação CLI** | `scripts/nova-oferta.sh` + `archetypes/` | Criação atômica de ofertas, validação MIME de imagem e conversão para WebP |
| **Cache de Build** | `resources/_gen/` | Artefatos WebP pré-compilados versionados no Git para deploys instantâneos no Cloudflare Pages |

---

## 🚀 Operação Local

### Pré-requisitos
* **Hugo Extended** (`v0.167+`) e **Go** (`1.21+`, para resolução de *Hugo Modules*)
* Utilitários POSIX + **`cwebp`** (`webp`) e **`file`** (para o pipeline de imagens)

### Fluxo de Trabalho

```bash
# 1. Clonar e baixar módulos do tema
git clone [https://github.com/backinbash/achadinhosflash.git](https://github.com/backinbash/achadinhosflash.git)
cd achadinhosflash && hugo mod get

# 2. Gerar nova oferta (cria Leaf Bundle em content/ofertas/ como rascunho)
./scripts/nova-oferta.sh "Nome do Produto" "Amazon" "R$ 499,90" "R$ 329,90" "https://link-afiliado" "/caminho/foto.jpg"

# 3. Visualizar localmente (incluindo rascunhos)
hugo server -D

# 4. Validar build de produção (modo estrito — zero warnings tolerados)
hugo --gc --minify --panicOnWarning
```

---

## 🔒 Segurança & Boas Práticas

* **Links Externos:** Todos os links de afiliados utilizam `rel="nofollow sponsored noopener noreferrer"`.
* **Higiene de Segredos:** Arquivos `.env*`, chaves privadas (`*.pem`, `*.key`) e diretórios temporários (`tmp/`) são bloqueados via `.gitignore`.
* **Rastreabilidade:** Toda alteração estrutural deve passar pelo build estrito antes do *push* para `main`.

---

**Mantenedor:** Julio Prata ([BackInBash](https://github.com/backinbash)) · **Status:** Infraestrutura validada; aguardando ativação de domínio e deploy no Cloudflare Pages.