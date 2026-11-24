# Abertura e onboarding do Movix

## Fluxo implementado

Ao tocar no ícone do aplicativo, o Movix exibe uma abertura nativa em Flutter (`lib/splash.dart`). A animação não usa vídeo, WebView, login ou internet. Ela apresenta:

1. fundo em degradê vinho/preto;
2. desenho progressivo do símbolo M;
3. entrada e pulso do ponto bordô;
4. nome e frase da marca;
5. cartões discretos de Treino, Evolução e Nutrição;
6. uma barra de carregamento visual enquanto os dados locais são inicializados.

A splash permanece por pelo menos 2,6 segundos e também aguarda a inicialização local terminar. Essa combinação evita que a tela de conteúdo apareça antes dos dados estarem prontos.

## Onboarding da primeira abertura

Depois da splash, somente na primeira utilização sem plano ou histórico, `lib/onboarding.dart` abre um fluxo de quatro perguntas:

- objetivo principal: massa muscular, força, emagrecimento/definição, glúteos/pernas ou saúde/hábito;
- experiência: iniciante, intermediário ou avançado;
- frequência sustentável: de 2 a 6 dias por semana;
- local: academia ou casa.

As respostas são gravadas localmente e enviadas para `recomendar()` em `lib/programas.dart`. A função compara nível, frequência, objetivo, local e equipamento contra os programas reais de `assets/programas.json`, exibindo o programa mais compatível e até duas alternativas.

## Decisões de produto

- A abertura é integrada ao aplicativo, não um MP4 separado.
- Os preços não aparecem nesse fluxo e nenhuma cobrança é ativada.
- Programas Premium continuam levando à tela informativa do Movix Pro.
- O onboarding pode ser pulado; nesse caso, o usuário continua usando o aplicativo normalmente.
- O fluxo deve ser validado no aparelho antes de publicar: primeira instalação, reabertura, pular onboarding, recomendação para casa, recomendação para academia e seleção de programa gratuito.

## Próxima evolução possível

Quando o proprietário definir o produto, pode-se acrescentar uma segunda etapa opcional com tempo disponível por treino, restrições/lesões e preferência de foco. Esses dados só devem entrar quando houver campos correspondentes nos programas ou regras claras para realmente alterarem a recomendação.
