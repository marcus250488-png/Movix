# Movix — Etapa 1: estabilização da base

## Objetivo

Preparar o aplicativo para operar localmente, sem exigir conta Google ou inicialização do Firebase, e separar os builds de teste dos builds assinados para publicação.

## Alterações aplicadas

- A inicialização do aplicativo abre diretamente a experiência principal (`Shell`).
- O onboarding continua sendo apresentado pelo fluxo existente quando aplicável.
- O `init()` não inicializa Firebase, não restaura sessão Google e mantém o prefixo local vazio, preservando o armazenamento local legado sem prefixo.
- A sincronização automática fica inativa nesta fase porque não há UID nem Firebase inicializado.
- Os atalhos de login/logout e o cartão de status da nuvem foram retirados da navegação de usuário.
- A tela Privacidade e dados informa que os registros permanecem no aparelho e recomenda exportar uma cópia JSON.
- A permissão de localização deixa de ser solicitada no primeiro acesso; deve ser solicitada somente no fluxo de localização da academia.
- O pedido de desativação de otimização de bateria deixa de aparecer automaticamente na primeira abertura.
- A permissão INTERNET duplicada foi removida do AndroidManifest.xml.
- O workflow executa `flutter analyze`, gera APK debug em push e reserva o APK release assinado para execução manual com secrets.
- O Gradle não usa mais a chave debug como fallback silencioso para release.

## Dados e compatibilidade

- O armazenamento atual continua em SharedPreferences. Não foi feita migração para SQLite nesta etapa para evitar alterações destrutivas sem inventário completo de todos os formatos persistidos.
- Os dados locais sem prefixo permanecem no mesmo conjunto de chaves.
- A tela Privacidade e dados mantém exportação e restauração JSON como mecanismo de cópia manual.
- Dependências Firebase/Google permanecem no projeto como código reservado para a futura fase de nuvem; não são inicializadas pelo fluxo de abertura atual.

## Validações realizadas neste ambiente

- JSON de exercícios, programas, anatomia e nutrição: leitura válida.
- Biblioteca: 60 exercícios.
- Programas: 8.
- IDs de exercícios usados nos programas: todos encontrados na biblioteca.
- Dias repetidos dentro dos programas: nenhum.
- Permissão INTERNET no manifesto: uma declaração.

## Validações pendentes

Este ambiente não possui Flutter nem Dart instalados. Portanto, ainda precisam ser executados no GitHub Actions ou em ambiente Flutter:

1. `flutter pub get`
2. `flutter analyze`
3. `flutter build apk --debug`
4. Testes funcionais em aparelho Android (abrir sem internet, salvar/editar treino, fechar/reabrir, conferir histórico e restaurar backup).

O arquivo `pubspec.lock` não estava presente no ZIP recebido. Recomenda-se gerar e versionar esse arquivo com a versão Flutter definida no workflow para tornar a resolução de dependências reproduzível.

## Observação de segurança

O modo local-first não equivale a criptografia de dados em repouso. SharedPreferences continua sendo armazenamento local simples. A revisão de proteção de dados, eventual migração de dados sensíveis e política de exclusão será tratada antes da publicação comercial.
