# Movix — Entrega das Fases 2 e 3 (desenvolvimento local)

## Incluído neste pacote
- Manutenção da splash Flutter como tela visual principal, com fundo nativo Android sem marca duplicada.
- Programas marcados como Premium direcionam para a apresentação Movix Pro; programas gratuitos continuam aplicáveis.
- Resumo semanal de desempenho permanece gratuito. Desempenho completo e detalhes de intensidade ficam identificados como recursos Pro.
- Tela Pro deixa explícito que não há contratação nem cobrança ativa nesta versão.
- Documentos informativos de Termos, Privacidade e Aviso de Saúde acessíveis no menu Mais.
- Minutas de documentos legais adicionadas em `docs/legal/`.
- Permissão de otimização de bateria não utilizada removida do AndroidManifest.

## Não incluído / deliberadamente adiado
- Google Play Console, cadastro de produtos, Billing, cobrança, restauração/validação de compras e publicação.
- Login Google e sincronização Firebase (Fase 4).
- Identificação e contato do responsável legal: aguardam informação do proprietário do app.

## Validação ainda necessária
- Executar `flutter analyze` e `flutter build apk --debug` em ambiente Flutter.
- Testar no aparelho: splash na primeira abertura, permissões opcionais, exportação/importação, fluxos gratuito/Pro e navegação dos documentos.
- Revisar licenças das imagens, fontes e dependências antes de distribuição pública.
- Revisão jurídica/privacidade das minutas antes de publicação.
