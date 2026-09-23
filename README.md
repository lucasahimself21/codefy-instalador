# Como instalar o CodeFy

O CodeFy é um agente que trabalha nos seus arquivos: você conversa com ele no terminal ou no navegador, e ele lê, cria e edita arquivos e roda comandos.

Não precisa de Docker nem de senha de administrador. Só do seu **token do CodeFy** (o admin manda): o instalador pede no final.

---

## Windows

1. Abra o **PowerShell**: clique no menu Iniciar, digite `PowerShell` e aperte Enter.
2. Copie o comando abaixo, cole no PowerShell (botão direito cola) e aperte Enter:

   ```
   irm https://raw.githubusercontent.com/lucasahimself21/codefy-instalador/main/install.ps1 | iex
   ```

3. No final ele testa a conexão. Se aparecer **"Seu IP não está cadastrado"**, envie o IP que aparece pro admin; depois que ele liberar, é só usar.

## Mac e Linux

1. Abra o **Terminal** (no Mac: `⌘ + Espaço`, digite `Terminal` e aperte Enter).
2. Copie o comando abaixo, cole e aperte Enter:

   ```
   curl -fsSL https://raw.githubusercontent.com/lucasahimself21/codefy-instalador/main/install.sh | bash
   ```

3. No final ele testa a conexão. Se aparecer **"Seu IP não está cadastrado"**, envie o IP que aparece pro admin; depois que ele liberar, é só usar.

---

## Usando

Abra um **terminal novo** (o que você usou pra instalar ainda não conhece o comando), entre na pasta do seu projeto e rode:

| Comando | O que faz |
|---|---|
| `codefy` | abre o CodeFy no terminal, nesta pasta |
| `codefy web` | abre o CodeFy no navegador: arquivos, chat e terminal lado a lado, nesta pasta |
| `codefy web C:\caminho\da\pasta` | abre o site já numa pasta |

No site, o botão de pasta (ao lado de "Arquivos") troca a pasta aberta e mostra as recentes, igual ao "Abrir pasta" do VS Code.

**Modo de aprovação:** por padrão o CodeFy edita arquivos sozinho e **pede sua permissão antes de rodar qualquer comando**. O modo Bypass (rodar tudo sem perguntar) existe, mas é por sua conta e risco. No terminal: `codefy --bypass`.

Dentro da pasta do projeto, o CodeFy cria `.codefy/` com as suas configurações:

- `.codefy/REGRAS.md`: regras que valem em toda conversa (ex.: "responda sempre em português").
- `.codefy/agentes/`: agentes com papel próprio; chame com `/nome` no chat.
- `.codefy/skills/`: passo a passo pra tarefas que você repete.

## Atualização

Toda vez que você abre o `codefy`, ele confere se tem versão nova e pergunta se quer atualizar. É só apertar Enter.

## Deu problema?

- **"codefy: command not found" / "não é reconhecido"**: feche o terminal e abra um novo.
- **"Seu IP não está cadastrado"**: envie o IP que aparece na mensagem pro admin. Se a sua internet mudar de IP (outro Wi-Fi, 4G), precisa liberar o novo também.
