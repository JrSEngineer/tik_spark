# Tik Spark :sparkles:

Você vai viralizar com seus vídeos nessa rede social

'O app foi construído utilizando o framework **Flutter** que utiliza a linguagem **Dart**, o super editor de código **Cursor**, que se destaca pelo uso de **IA** integrada ao ambiente de desenvolvimento e a Bluesky como base para busca dos vídeos.

## Execução

1. Para executar o app localmente, clone o repositório utilizando:

```bash
git clone https://github.com/JrSEngineer/tik_spark.git
```

2. Rode o comando no diretório do app:

```bash
flutter pub get
```

3. Execute via terminal o comando:

```bash
flutter run
```

## Desenvolvimento

Para integração com a Bluesky foi utilizado um package dart:

```yaml
bluesky: ^0.15.8
```

E algumas outras dependências:

```yaml
video_player: ^2.8.2
chewie: ^1.7.5
dio: ^5.8.0+1
```

Para que o feed da bluesky fosse acessado, foi necessária uma autenticação de um usuário existente, que foi realizada mediante a passagem das minhas credenciais próprias (identifier e password), que estão sendo providas por um endpoint de uma API.

## Uso de Inteligência Artificial

- Com o auxílio do Cursor, as primeiras páginas e widgets foram gerados;
- Algumas pesquisas sobre o at protocol foram realizadas, e em conjunto com a documentação oficial, várias dúvidas foram sanadas;
- O cursor se mostrou eficiente na execução de tarefas como componentização, geração de widgets, dentre outras (como auxiliar no scroll infinito);
- Formatação do README que aqui vos fala.

