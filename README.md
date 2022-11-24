# CONTA GOTAS

[Veja uma versão funcional do app aqui](https://toolkit.shinyapps.io/conta-gotas/)

* usuário: _admin_

* senha: _abelhasmatadoras_

Esse é um aplicativo simples, desenvolvido em cima de R/Shiny e Google Sheets, para visualizar de maneira simples, gratuita e direta a contabilidade e balanço de pequenas empresas. Às vezes é melhor do que ficar se virando com um monte de planilhas.

![](https://live.staticflickr.com/65535/52520048596_77894a46f8_b.jpg)

Esse app é baseado em 2 componentes principais: 

* Um app de Shiny (framework de R)

* Google Sheets

A partir de uma planilha de Google Sheets, o aplicativo vai se atualizando automaticamente (a cada refresh) à medida que novos dados vão sendo inputados ou modificados.

A hospedagem pode ser feita via [Shinyapps.io](https://www.shinyapps.io), que tem um tier gratuito de 25 horas mensais de uso de até 5 apps.

Foi desenvolvido por [Sérgio Spagnuolo](https://twitter.com/sergiospagnuolo), do Volt Data Lab.

É o mesmo app que usamos para nós mesmos aqui no Volt.

## O que você vai precisar

* 1 conta no Google para usar o Sheets

* Fazer download do [Rstudio](https://posit.co/download/rstudio-desktop/)

* Uma conta no [Shinyapps](https://www.shinyapps.io)

## Passo 1
#### GOOGLE SHEETS

* Faça uma cópia deste [template](https://docs.google.com/spreadsheets/d/12QRBFa-8U6QHoX7DOj3e_o1Ef7n-BTFklMPOP9qEFUc/edit#gid=1797569613) no Google Sheets. 

Vá em:

* arquivo > compartilhar > publicar na web > caixa > valores separados por vírgula (para cada uma das abas)

**NOTA IMPORTANTE**: Ao fazer isso, você está tornando público o link desses dados em formato `.csv`. É impossível alguém adivinhar essa URL ao acaso, mas tenha cuidado ao compartilhar esse link ou sua aplicação com alguém que não é de sua confiança, considerando que o balanço da sua empresa possui dados sensíveis. A sua tabela principal continuará sendo privada para edição. 

O aplicativo possui uma barreira com login e senha baseada no pacote [shinymanager](https://datastorm-open.github.io/shinymanager/) que não carrega seu código nem nenhum dado até que as credenciais corretas sejam inputadas. Isso garante uma camada de segurança para que seus dados não sejam expostos indevidamente.

Vamos utilizar os 3 csvs gerados pelo compartilhamento, eles serão basicamente seu banco de dados.

**DICA**: se você não quiser gerar esse link de arquivo aberto, você pode se virar com a autenticação do Google Sheets utilizando o pacote R [googlesheets4](https://googlesheets4.tidyverse.org) e [abjutils](https://github.com/abjur/abjutils).

Os valores do template são gerados randomicamente, e cabe a você organizar seu próprio balanço.

Evite mudar o nome das colunas ou removê-las, caso contrário o código pode quebrar e as coisas vão parar de funcionar caso você não ajuste o código principal (o app foi configurado em cima do nome dessas colunas).

## Passo 2
#### Trabalhando com Shiny

[Shiny](https://shiny.rstudio.com) é um framework de R para criação de dashboards e aplicações. Dá pra fazer uma caralhada de coisas com ele.

Não cabe aqui explicar a estrutura de como o Shiny funciona. O template deste repositório está funcional e, se você quiser, pode ir brincando com ele com o tempo, caso tenha familiaridade com a linguagem. 

O que é necessário saber é: 

* O arquivo principal do Shiny é o `app.R`, é ele que monta o aplicativo

* No folder `R` estão os módulos utilizados pelo app: painel geral, receitas e despesas

* No folder `www` é possível customizar os visuais do app usando CSS

* O arquivo `functions.R` contém algumas funções úteis

#### Configurando o app.R

A única coisa que você precisa configurar são as credenciais e senhas do admin e dos usuários.

```
credentials <- data.frame(
  user = c("admin", "user", "convidado"),
  password = c("abelhasmatadoras", "ricadordarin", "cachorrosmalditos"),
  admin = c(TRUE, FALSE, FALSE),
  comment = "Use a senha para entrar",
  stringsAsFactors = FALSE
)
```

Se quiser, também pode colocar o link do seu Google Sheets ali no último ítem da barra de menu para facilitar o acesso.

#### Configuração os dados nos módulos

O painel geral é o mais complexo. Ele é basicamente um agregador dos seus dados, valendo-se de gráficos interativos baseados no pacote Plotly. 

Dentro do folder `R`, acesse o arquivo `mod_painel.R` e substitua as URLs com os csvs do Google Sheets. 

Substitua as URLs ali dos TABELÕES.

A mesma coisa precisa ser feita no `mod_receitas.R` (dados de caixa e receita) e no `mod_despesas.R` (dados de despesas). 

Lembrando que tudo o que você precisa fazer é substituir a URL pelos dados de Google Sheets.

## Passo 3
#### Deploy no Shinyapps

Crie uma conta gratuita no [Shinyapps](https://www.shinyapps.io), e instale a biblioteca `rsconnect` no seu R. 

```
install.packages('rsconnect')
```

Basicamente, dentro do RStudio tem um botão que envia sua aplicação diretamente para o Shinyapps. É bem fácil mesmo. 

Seguem os prints do caminho.

* No canto superior direito, clique na setinha para baixo (_não_ no ícone azul) e em "manage accounts"

![](https://live.staticflickr.com/65535/52520526880_89b6cd80e4_o.png)

* Clique em conectar 

![](https://live.staticflickr.com/65535/52520326074_7ecfabb65e_o.png)

* Escolha a opção ShinyApps.io

![](https://live.staticflickr.com/65535/52520326069_a37476e6f1_o.png)

* Adicione seu token ali (só copiar e colar o que o Shinyapps fornece)

![](https://live.staticflickr.com/65535/52520526890_7a8aa0f12d_o.png)

Já que tem coisa boa já pronta, esse passo basta ir direto pro blog do pessoal do Curso-R (inclusive recomendo que façam os cursos deles). [Aqui o link de referência](https://blog.curso-r.com/posts/2020-06-18-shinyappsio/).

### LICENÇA 

Esse código é aberto e licenciado sob a Licença MIT, que basicamente diz que pode ser usado para qualquer finalidade ou restrição, inclusive uso comercial, com modificações e licenciamento próprio. 

Esse código é fornecido conforme disponibilizado aqui, sem suporte de qualquer tipo e sem responsabilização de seus criadores em caso de mau uso.

##### MIT LICENCE

Copyright 2022 Volt Data Lab

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##### Licença MIT (Expat)

Copyright 2022 Volt Data Lab

É concedida permissão, livre de cobrança, a qualquer pessoa que obtenha uma cópia deste software e dos arquivos de documentação associados (o "Software"), para lidar com o Software sem restrição, incluindo sem limitação os direitos de usar, copiar, modificar, mesclar, publicar, distribuir, sublicenciar e/ou vender cópias do Software e permitir a pessoas a quem o Software é fornecido para tal, sujeito às seguintes condições:

A notificação de copyright acima e esta notificação de permissão deverão ser incluídas em todas as cópias ou porções substanciais do Software

O SOFTWARE É FORNECIDO "TAL COMO ESTÁ", SEM GARANTIA DE QUALQUER TIPO, EXPRESSA OU IMPLÍCITA, INCLUINDO MAS NÃO SE LIMITANDO ÀS GARANTIAS DE COMERCIALIZAÇÃO, CONVENIÊNCIA PARA UM PROPÓSITO ESPECÍFICO E NÃO INFRAÇÃO. EM NENHUMA SITUAÇÃO DEVEM AUTORES(AS) OU TITULARES DE DIREITOS AUTORAIS SEREM RESPONSÁVEIS POR QUALQUER REIVINDICAÇÃO, DANO OU OUTRAS RESPONSABILIDADES, SEJA EM AÇÃO DE CONTRATO, PREJUÍZO OU OUTRA FORMA, DECORRENTE DE, FORA DE OU EM CONEXÃO COM O SOFTWARE OU O USO OU OUTRAS RELAÇÕES COM O SOFTWARE.