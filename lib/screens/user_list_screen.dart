import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';

class UserListScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;

  const UserListScreen({super.key, this.onToggleTheme, this.themeMode});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = false;
  String _error = '';
  SearchType _searchType = SearchType.name;
  Timer? _debounceTimer;
  bool _isTableView = false;

  // Paginação e ordenação
  int _rowsPerPage = 10;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final users = await _apiService.fetchUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(_searchController.text);
    });
  }

  void _performSearch(String query) {
    final queryLower = query.toLowerCase();
    setState(() {
      _filteredUsers = query.isEmpty
          ? _users
          : _users.where((user) {
              return _searchType == SearchType.name
                  ? user.name.toLowerCase().contains(queryLower)
                  : user.registration.toLowerCase().contains(queryLower);
            }).toList();
      _currentPage = 0; // Reset página ao pesquisar
      _sortUsers(); // Reaplica ordenação
    });
  }

  void _sortUsers() {
    _filteredUsers.sort((a, b) {
      int result;
      switch (_sortColumnIndex) {
        case 0: // Nome
          result = a.name.compareTo(b.name);
          break;
        case 1: // Matrícula
          result = a.registration.compareTo(b.registration);
          break;
        case 2: // Email
          result = a.email.compareTo(b.email);
          break;
        default:
          result = 0;
      }
      return _sortAscending ? result : -result;
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortUsers();
    });
  }

  // Métodos de paginação
  List<User> get _currentPageUsers {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(
      0,
      _filteredUsers.length,
    );
    return _filteredUsers.sublist(startIndex, endIndex);
  }

  int get _totalPages => (_filteredUsers.length / _rowsPerPage).ceil();

  void _goToFirstPage() {
    setState(() {
      _currentPage = 0;
    });
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _goToLastPage() {
    setState(() {
      _currentPage = _totalPages - 1;
    });
  }

  void _copyMatricula(String matricula) {
    Clipboard.setData(ClipboardData(text: matricula));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Matrícula $matricula copiada!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuários'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(_isTableView ? Icons.view_list : Icons.table_chart),
            onPressed: () {
              setState(() {
                _isTableView = !_isTableView;
              });
            },
            tooltip: _isTableView ? 'Ver como lista' : 'Ver como tabela',
          ),
          if (widget.onToggleTheme != null)
            IconButton(
              icon: Icon(
                theme.brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: widget.onToggleTheme,
              tooltip: 'Alternar tema',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText:
                        'Pesquisar por ${_searchType == SearchType.name ? 'Nome' : 'Matrícula'}',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<SearchType>(
                value: _searchType,
                onChanged: (value) {
                  setState(() {
                    _searchType = value!;
                    _performSearch(_searchController.text);
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: SearchType.name,
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 8),
                        const Text('Nome'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: SearchType.registration,
                    child: Row(
                      children: [
                        const Icon(Icons.badge, size: 16),
                        const SizedBox(width: 8),
                        const Text('Matrícula'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_filteredUsers.length != _users.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${_filteredUsers.length} de ${_users.length} usuários encontrados',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando usuários...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Erro ao carregar usuários'),
            const SizedBox(height: 8),
            Text(_error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Nenhum usuário encontrado'
                  : 'Nenhum resultado para "${_searchController.text}"',
            ),
          ],
        ),
      );
    }

    return _isTableView ? _buildTableView() : _buildListView();
  }

  Widget _buildListView() {
    return Column(
      children: [
        // Feedback de usuários carregados/encontrados
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            _filteredUsers.length != _users.length
                ? '${_filteredUsers.length} de ${_users.length} usuários encontrados'
                : '${_users.length} usuários carregados',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
        // Lista de usuários
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Matrícula: ${user.registration}'),
                      Text('Email: ${user.email}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'copy') {
                        _copyMatricula(user.registration);
                      } else if (value == 'details') {
                        _showUserDetails(user);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 16),
                            SizedBox(width: 8),
                            Text('Copiar Matrícula'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.info, size: 16),
                            SizedBox(width: 8),
                            Text('Ver Detalhes'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableView() {
    return Column(
      children: [
        // Cabeçalho da tabela
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              _filteredUsers.length != _users.length
                  ? '${_filteredUsers.length} de ${_users.length} usuários encontrados'
                  : '${_users.length} usuários carregados',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        // Tabela centralizada
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: DataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  columns: [
                    DataColumn(
                      label: const Row(
                        children: [
                          Icon(Icons.person, size: 16),
                          SizedBox(width: 4),
                          Text('Nome'),
                        ],
                      ),
                      onSort: (columnIndex, ascending) =>
                          _onSort(columnIndex, ascending),
                    ),
                    DataColumn(
                      label: const Row(
                        children: [
                          Icon(Icons.badge, size: 16),
                          SizedBox(width: 4),
                          Text('Matrícula'),
                        ],
                      ),
                      onSort: (columnIndex, ascending) =>
                          _onSort(columnIndex, ascending),
                    ),
                    DataColumn(
                      label: const Row(
                        children: [
                          Icon(Icons.email, size: 16),
                          SizedBox(width: 4),
                          Text('Email'),
                        ],
                      ),
                      onSort: (columnIndex, ascending) =>
                          _onSort(columnIndex, ascending),
                    ),
                    const DataColumn(
                      label: Row(
                        children: [
                          Icon(Icons.settings, size: 16),
                          SizedBox(width: 4),
                          Text('Ações'),
                        ],
                      ),
                    ),
                  ],
                  rows: _currentPageUsers.map((user) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  user.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.registration,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(user.email, overflow: TextOverflow.ellipsis),
                        ),
                        DataCell(
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'copy') {
                                _copyMatricula(user.registration);
                              } else if (value == 'details') {
                                _showUserDetails(user);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'copy',
                                child: Row(
                                  children: [
                                    Icon(Icons.copy, size: 16),
                                    SizedBox(width: 8),
                                    Text('Copiar Matrícula'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'details',
                                child: Row(
                                  children: [
                                    Icon(Icons.info, size: 16),
                                    SizedBox(width: 8),
                                    Text('Ver Detalhes'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        // Barra de paginação inferior
        _buildPaginationBar(),
      ],
    );
  }

  Widget _buildPaginationBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Seletor de itens por página
          Row(
            children: [
              const Text('Linhas por página:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _rowsPerPage,
                onChanged: (value) {
                  setState(() {
                    _rowsPerPage = value ?? 10;
                    _currentPage = 0; // Reset para primeira página
                  });
                },
                items: [5, 10, 20, 50].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
            ],
          ),
          // Informações da página atual
          Text(
            '${_currentPage + 1} de ${_totalPages > 0 ? _totalPages : 1} (${_filteredUsers.length} itens)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          // Controles de navegação
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: _currentPage > 0 ? _goToFirstPage : null,
                tooltip: 'Primeira página',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0 ? _goToPreviousPage : null,
                tooltip: 'Página anterior',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages - 1
                    ? _goToNextPage
                    : null,
                tooltip: 'Próxima página',
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: _currentPage < _totalPages - 1
                    ? _goToLastPage
                    : null,
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Detalhes do Usuário'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${user.name}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Matrícula: ${user.registration}'),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () => _copyMatricula(user.registration),
                  tooltip: 'Copiar matrícula',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Email: ${user.email}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
