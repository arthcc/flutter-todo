# Flutter Todo App

Um aplicativo simples de gerenciamento de tarefas desenvolvido com Flutter.

## Funcionalidades

- Adicionar novas tarefas com título e descrição
- Editar tarefas existentes
- Excluir tarefas (deslizando para a esquerda)
- Marcar tarefas como concluídas
- Navegação entre telas (lista de tarefas, adicionar/editar tarefa, sobre)

## Requisitos Técnicos Implementados

- ✅ **Entrada e Saída**: O aplicativo permite a entrada de dados através de formulários (caixas de edição para título e descrição da tarefa) e exibe a saída em forma de lista.
- ✅ **Navegação**: Implementado sistema de navegação entre três telas (Home, Add/Edit, About).
- ✅ **Uso de Scaffold**: Todas as telas utilizam o widget Scaffold que fornece uma estrutura básica de layout do Material Design.
- ✅ **Lista com Exclusão e Atualização**: A tela principal exibe uma lista de tarefas que podem ser excluídas (com gesto de deslize) e atualizadas (navegando para a tela de edição).
- ✅ **Três Páginas**: O aplicativo possui três páginas distintas:
  1. Página principal com a lista de tarefas
  2. Página para adicionar e editar tarefas
  3. Página "Sobre" com informações do aplicativo

## Estrutura do Projeto

```
lib/
├── main.dart - Ponto de entrada do aplicativo
├── models/
│   └── task.dart - Modelo de dados para as tarefas
└── screens/
    ├── home_screen.dart - Tela principal com a lista de tarefas
    ├── add_edit_task_screen.dart - Tela para adicionar/editar tarefas
    └── about_screen.dart - Tela com informações sobre o aplicativo
```

## Como Rodar o Projeto

1. Certifique-se de ter o Flutter instalado em seu ambiente
2. Clone este repositório
3. Execute `flutter pub get` para instalar as dependências
4. Execute `flutter run` para iniciar o aplicativo

## Notas

Este aplicativo foi desenvolvido como exemplo para demonstrar os conceitos básicos do Flutter, incluindo:
- Gerenciamento de estado com StatefulWidget
- Navegação entre telas
- Uso de formulários e validação
- Manipulação de listas
- Layout com Material Design 