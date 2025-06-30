# 📱 Lista de Usuários App - Flutter

Aplicativo Flutter que consome uma API externa para exibir lista de usuários com filtro dinâmico, conforme requisitos de avaliação na disciplina de Programação Móvel no IFPA Campus Tucuruí.

## 🚀 Funcionalidades

- **Consumo de API**: Conecta ao endpoint `https://ifpaserver.org:4443/usuarios`
- **Lista de usuários**: Exibe nome, matrícula e email em cards
- **Filtro reativo**: Busca por nome ou matrícula em tempo real
- **Visualização dupla**: Alternância entre lista e tabela
- **Temas**: Suporte a tema claro/escuro
- **Feedback visual**: Indicadores de carregamento, erro e estados vazios

## 🛠️ Como Executar

1. **Clone o repositório**

   ```bash
   git clone <https://github.com/vitormezz/listar-usuarios-flutter.git>
   cd lista_usuarios_app
   ```

2. **Instale as dependências**

   ```bash
   flutter pub get
   ```

3. **Execute a aplicação**
   ```bash
   flutter run
   ```

## 🏗️ Estrutura

```
lib/
├── models/user.dart           # Modelo de dados
├── services/api_service.dart  # Comunicação com API
├── screens/user_list_screen.dart # Tela principal
├── constants/app_constants.dart # Constantes
└── main.dart                  # Ponto de entrada
```

## 📚 Dependências

- `flutter`: SDK do Flutter
- `http`: Requisições HTTP
- `cupertino_icons`: Ícones

## 🤝 Agradecimentos

Agradecimentos especial ao professor [Karlay Costa](https://github.com/karlaycosta) por sempre ministrar as disciplinas com maestria!

## 👤 Equipe

- [Vitor Mezzomo](https://github.com/vitormezz)
- [Pedro Modesto](https://github.com/JKLModesto)
- [João Pedro Cavalcante](https://github.com/JoaoPedroCavalcante)
