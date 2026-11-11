# Firebase

Projeto: **`nutri-app-42226`** (plano gratuito Spark).

| Serviço | Uso | Status |
|---------|-----|--------|
| Authentication (e-mail/senha) | Login da nutricionista e dos pacientes | ✅ v0.4 |
| Cloud Firestore | Cadastro, cardápio, receitas, diário, água, chat (incluindo fotos) | ✅ v0.4 |
| Cloud Storage | Fotos em arquivos separados | ⏳ requer plano Blaze |
| Cloud Functions + Cloud Messaging | Notificação com o app fechado | ⏳ requer plano Blaze |

A configuração do app está em `lib/firebase_options.dart` (valores do
`google-services.json`; não são segredos: quem protege os dados são as regras).

## Configuração inicial (uma vez)

### 1. Authentication
Console → **Authentication → Método de login → E-mail/senha → Ativar**.

### 2. Firestore
Console → **Firestore Database → Criar banco de dados**:
edição **Standard**, ID `(default)`, local **southamerica-east1 (São Paulo)**, modo **produção**.

### 3. Regras de segurança
Console → **Firestore Database → Regras** → apagar o conteúdo, colar o arquivo
[`firebase/firestore.rules`](../firebase/firestore.rules) inteiro → **Publicar**.

Sempre que esse arquivo mudar no repositório, publicar de novo.

### 4. E-mail da nutricionista (documento `config/clinic`)
O e-mail **não fica no código** (o repositório é público). Cadastre no console:

Console → **Firestore Database → Dados → + Iniciar coleção**
- ID da coleção: `config`
- ID do documento: `clinic`
- Campo: `nutritionistEmail` · tipo **string** · valor: e-mail da nutricionista (em minúsculas)
- **Salvar**

### 5. Primeiro acesso da nutricionista
1. No app, tocar em **"Sou a nutricionista e é meu primeiro acesso"**, informar o
   e-mail cadastrado acima e criar uma senha.
2. Abrir o e-mail de confirmação (verificar também o spam) e tocar no link.
3. Voltar ao app e tocar em **"Já confirmei"**.

> Faça isso logo: até a nutricionista criar a conta, qualquer pessoa poderia
> registrar esse e-mail. Mesmo assim, sem confirmar o e-mail ela não ganha acesso.

## Como os acessos funcionam

- **Nutricionista**: e-mail igual ao de `config/clinic` **e** e-mail confirmado.
- **Paciente**: criado pela nutricionista (aba Pacientes → Novo paciente), que define
  uma senha provisória e envia ao paciente. O app cria o login usando uma instância
  secundária do Firebase, sem deslogar a nutricionista.
- Contas criadas por conta própria que não estejam em `patients/` não acessam nada.

As regras (`firebase/firestore.rules`) garantem:
- paciente lê/escreve **somente** os próprios dados e só altera `lastSeenAt` e
  `lastPatientMessageAt` no próprio cadastro (não altera o cardápio);
- somente a nutricionista cria pacientes, edita cardápios e publica receitas;
- cada lado só envia mensagens como ele mesmo; mensagens não podem ser editadas.

## Fotos sem o Cloud Storage

Enquanto o projeto estiver no plano gratuito, as fotos (chat e receitas) são
reduzidas para no máximo 900 px / qualidade 65 (normalmente 60–200 KB) e gravadas
como `data:image/jpeg;base64,...` dentro do documento. O limite do Firestore é
1 MB por documento; o app recusa fotos acima de 600 KB.

Quando o plano Blaze for ativado, migrar para o Storage (`chat_images/`,
`recipe_images/`) e guardar só a URL no documento.

## Notificações

| Situação | Como funciona hoje |
|----------|-------------------|
| Lembretes de refeição | Notificação local agendada no aparelho ✅ |
| Mensagem nova da nutricionista com o app aberto ou em segundo plano | Notificação local disparada pelo app ✅ |
| Mensagem nova com o app **fechado** | ⏳ precisa de Cloud Function + FCM (plano Blaze) |

Plano para o Blaze: o app salva o token FCM em `patients/{uid}.fcmTokens` (e o da
nutricionista em `config/nutriTokens`); uma Cloud Function `onCreate` em
`patients/{uid}/messages/{id}` envia o push ao destinatário.

## Custos

No plano gratuito não há cobrança. Cota diária do Firestore: 50 mil leituras,
20 mil gravações, 1 GB armazenado — suficiente para um consultório.

## LGPD

Dados de alimentação e saúde são **dados pessoais sensíveis**. Antes de uso real
com pacientes:

- termo de consentimento no primeiro acesso (pendente);
- política de privacidade (pendente);
- opção de excluir conta e dados (pendente);
- acesso restrito pelas regras acima ✅;
- dados armazenados no Brasil (`southamerica-east1`) ✅.
