# Movix — Política de Privacidade (minuta de desenvolvimento)

**Status:** minuta baseada no funcionamento observado no código desta versão. Confirmar em aparelho e revisar antes de publicar. Preencher os dados do controlador/responsável.

## 1. Funcionamento local
O app não exige conta para as funções principais. Login Google e sincronização Firebase não estão ativos nesta etapa. Os pacotes relacionados a esses serviços permanecem no projeto para possível uso futuro, mas não são inicializados pelo fluxo local-first atual.

## 2. Dados mantidos no aparelho
Podem ser armazenados: plano e histórico de treinos, exercícios personalizados, séries, cargas, avaliações e medidas corporais, metas de água e passos, registros de alimentação, preferências e progresso. São usados para oferecer as funções do aplicativo.

## 3. Permissões
- **Atividade física:** usada pelo sensor do aparelho para contar passos, se autorizada.
- **Localização:** solicitada somente ao escolher a busca de academias próximas.
- **Internet:** necessária para buscas online de alimentos e academias.
O usuário pode negar permissões; funções opcionais relacionadas deixam de operar.

## 4. Serviços externos acionados pelo usuário
- **Open Food Facts:** recebe o termo de busca para retornar alimentos e informações nutricionais.
- **Overpass API / OpenStreetMap:** recebe consulta geográfica com coordenadas para localizar academias próximas.
Consulte também as políticas dos respectivos provedores. Evite inserir dados pessoais nos termos de busca.

## 5. Compartilhamento e exportação
O Movix não sincroniza os registros locais com uma conta ou servidor nesta versão. Se o usuário exportar, copiar ou compartilhar dados, o destino escolhido passa a receber a cópia.

## 6. Retenção e exclusão
Os dados permanecem no armazenamento do app até serem removidos, os dados do aplicativo serem limpos ou o app ser desinstalado, observadas as cópias de segurança geridas pelo sistema operacional. Arquivos exportados devem ser eliminados separadamente.

## 7. Segurança
O armazenamento local é mantido no espaço privado do aplicativo, mas SharedPreferences não oferece criptografia individual dos registros nesta versão. O backup automático Android está desativado no manifesto; o usuário pode exportar manualmente seus dados. Nenhuma solução garante segurança absoluta; proteja o aparelho e as cópias exportadas.

## 8. Controlador e contato — preencher antes da distribuição
- Responsável/controlador: **[PREENCHER]**
- E-mail para privacidade: **[PREENCHER]**
- Canal para solicitações de titulares: **[PREENCHER]**
- Prazo e procedimento de resposta: **[DEFINIR]**
