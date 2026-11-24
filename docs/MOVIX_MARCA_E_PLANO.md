# Movix — marca e plano de desenvolvimento

## Identidade
- Nome: Movix | Pacote Android: `com.movix.app`.
- Bordô vivo `#A3203F`; bordô escuro `#3A0F1C`; bege `#E8DCC8`; bege suave `#C9B79C`; fundo vinho-preto `#120609`; superfície `#241116`; texto secundário `#B3A394`.
- Ícone: M em linha de movimento bege sobre fundo bordô, com ponto rosa.

## Roteiro aprovado

### Fase 0 — Identidade e estrutura inicial — concluída
- Nome, pacote, identidade visual e estrutura Flutter.

### Fase 1 — Produto gratuito e estabilização — concluída
- Produto local-first, armazenamento local, treinos, biblioteca, evolução, nutrição, histórico e exportação/restauração.
- Login Google e Firebase adiados para a Fase 4.

### Fase 2 — Premium — em andamento
- Limpeza do cardápio pessoal e dos vídeos antigos concluída.
- Programas gratuitos e Premium identificados; recursos Premium apresentam a tela Movix Pro.
- Resumo semanal permanece gratuito; relatórios históricos/detalhados ficam identificados como Pro.
- Ainda falta validar todos os fluxos no aparelho e evoluir os relatórios avançados.
- Google Play Billing, produtos, preços e cobrança foram deliberadamente adiados a pedido do proprietário.

### Fase 3 — Privacidade, segurança e preparação documental — em andamento
- Minutas de Termos de Uso, Política de Privacidade e Aviso de Saúde incluídas no app e em `docs/legal/`.
- Revisão de permissões e transparência de serviços externos.
- Faltam dados de identificação/contato do responsável, revisão jurídica, verificação final de licenças e testes completos.

### Fase 4 — Login, nuvem e integrações — futura
- Login Google, Firebase, sincronização, backup em nuvem e integrações serão avaliados somente após estabilização.

## Decisões que permanecem
- Não reconstruir o app do zero.
- Local-first; a abertura não depende de login, rede ou Firebase.
- Não reintroduzir vídeos até revisão de edição e direitos comerciais.
- Não iniciar cobrança ou publicação na Play Store nesta etapa.
- Não declarar documentos legais finais sem identificação e contato do responsável e revisão adequada.

## Pendências do responsável antes de distribuição pública
- Informar nome/identificação do responsável e e-mail/canal de privacidade.
- Revisar direitos comerciais das imagens e demais mídias.
- Revisar licença/termos das bibliotecas e fontes utilizadas.
- Fazer revisão jurídica dos documentos e confirmar os fluxos reais do app.
- Criar keystore e segredos somente quando for retomada a preparação de release assinado.
