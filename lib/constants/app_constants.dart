class AppConstants {
  // API
  static const String apiBaseUrl = 'https://ifpaserver.org:4443';
  static const String usuariosEndpoint = '/usuarios';

  // Paginação
  static const int defaultLinhasPorPagina = 5;
  static const int pageSize = 10; // Para a nova implementação
  static const List<int> opcoesPaginacao = [5, 10, 20, 50];

  // Timeout
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Strings
  static const String appTitle = 'Lista de Usuários';
  static const String erroCarregarUsuarios = 'Erro ao carregar usuários';
  static const String tentarNovamente = 'Tentar novamente';
}

enum TipoPesquisa {
  nome('nome', 'Nome', 'Buscar por nome'),
  matricula('matricula', 'Matrícula', 'Buscar por matrícula');

  const TipoPesquisa(this.value, this.displayName, this.placeholder);

  final String value;
  final String displayName;
  final String placeholder;
}

enum SearchType {
  name('name', 'Nome', 'Buscar por nome'),
  registration('registration', 'Matrícula', 'Buscar por matrícula');

  const SearchType(this.value, this.displayName, this.placeholder);

  final String value;
  final String displayName;
  final String placeholder;
}
