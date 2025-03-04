# vpngw-recreate-env

## はじめに
本 Bicep は VPNGW (ルートベース) を再作成する Bicep です

常に利用しているわけではないが、動作確認のために検証環境を残しておきたいような場合に VPNGW のみ削除して、必要な時にデプロイを行うということを目的として作成しています（料金が高い VPNGW を利用するタイミングでのみデプロイすることで費用を下げるため）

## 構成図
![](/images/vpngw-recreate-topology.png)

> [!NOTE]
> - 本環境では 仮想ネットワークとサブネットは作成されません 
> - リソースグループ名、仮想ネットワーク名はすでに存在するものを指定する必要があります
> - 本Bicepは約30分程度で完了します (VPN Gateway の作成に時間が掛かるため、少し長めとなります。ご注意ください)

### 前提条件
ローカルPCでBicepを実行する場合は Azure CLI と Bicep CLI のインストールが必要となります。私はVS Code (Visual Studio Code) を利用してBicepファイルを作成しているのですが、結構使いやすいのでおススメです。以下リンクに VS Code、Azure CLI、Bicep CLI のインストール手順が纏まっています

https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/bicep/install

## 使い方
本リポジトリをローカルPCにクローンし、パラメータファイル (main.prod.bicepparam) を修正してご利用ください

**main.prod.bicepparam**
![](/images/vpngw-recreate-bicepparam.png)

※Git を利用できる環境ではない場合はファイルをダウンロードしていただくでも問題ないと思います。その場合は、以下の構成でローカルPCにファイルを設置してください

```
main.bicep
main.prod.bicepparam
∟ modules/
　　∟ hubEnv.bicep
　　∟ onpreEnv.bicep
　　∟ vpnConnection.bicep
```

## 実行手順 (Git bash)

#### 1. Azureへのログインと利用するサブスクリプションの指定
```
az login
az account set --subscription <利用するサブスクリプション名>
```
> [!NOTE]
> az login を実行するとWebブラウザが起動するので、WebブラウザにてAzureへのログインを行う

#### 2. ディレクトリの移動（main.bicep を設置したディレクトリへ移動）
```
cd <main.bicepを設置したディレクトリ>
```

#### 3. デプロイの実行
```
az deployment sub create --location japaneast -f main.bicep -p main.prod.bicepparam
```
> [!NOTE]
> コマンドで指定する `--location` はメタデータを格納する場所の指定で、Azure リソースのデプロイ先ではない (メタデータなのでどこでも問題ないが、特に要件がなければAzureリソースと同一の場所を指定するで問題ない) 

#### 4. Azureからのログアウト
```
az logout
```

## その他
本 Bicep では Local Network Gateway のアドレス空間は VPNGW が存在する仮想ネットワークのみが追加されて作成されます。必要に応じて、アドレス空間を追加するようにしてください

本 Bicep で作成される LNG のアドレス空間

[Azure側のLNG]
![](/images/vpngw-recreate-AzureLNG.png)

[オンプレ側のLNG]
![](/images/vpngw-recreate-OnpreLNG.png)

詳細は以下の記事をご参照ください

- [3. ローカルネットワークゲートウェイの作成 (Azure側)](https://zenn.dev/microsoft/articles/zenn-vpngw-instruction#3.-%E3%83%AD%E3%83%BC%E3%82%AB%E3%83%AB%E3%83%8D%E3%83%83%E3%83%88%E3%83%AF%E3%83%BC%E3%82%AF%E3%82%B2%E3%83%BC%E3%83%88%E3%82%A6%E3%82%A7%E3%82%A4%E3%81%AE%E4%BD%9C%E6%88%90-(azure%E5%81%B4))
- [4. ローカルネットワークゲートウェイの作成 (Onpre側)](https://zenn.dev/microsoft/articles/zenn-vpngw-instruction#4.-%E3%83%AD%E3%83%BC%E3%82%AB%E3%83%AB%E3%83%8D%E3%83%83%E3%83%88%E3%83%AF%E3%83%BC%E3%82%AF%E3%82%B2%E3%83%BC%E3%83%88%E3%82%A6%E3%82%A7%E3%82%A4%E3%81%AE%E4%BD%9C%E6%88%90-(onpre%E5%81%B4))

## 自分用メモ（備忘録）
自分の検証環境で良く利用するアドレスは以下の通りとなるので、VPNGW を再作成した際は アドレス空間の追加を忘れないようにする

[Azure環境]
- 10.0.0.0/16 (Hub)
- 10.1.0.0/16 (Spoke1)
- 10.2.0.0/16 (Spoke2)

[オンプレ環境]
- 172.16.0.0/16 (Onpre)
- 172.20.0.0/16 (Onpre-AD/Onpre-DNS)
