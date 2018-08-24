# hyponymy-1.0
dockerfile for hyponymy-1.0


上位下位関係抽出ツール（hyponymy-1.0）の環境整備のため、どうしても自動化したいと思って、スタートしました。

Linux環境でdockerを利用して、環境づくりを進んでいます。

uploadのDockerfileはテスト済みです。


最初流行っているalpineをベースで作って行こうと思って、いろいろ試してみたが、packageのinstallでだんだん膨らんで、
ubuntuベースで作ったものと同じ容量になります。

以上の理由で、ベースはubuntu 18.04 offical を選びました。

今Dockerfile の作成が終了しました。テスト段階に進んでおります。
各環境でテストしたいと思います。

Linux OS のテストが終了しました。
build : OK
  run : OK

container構成までOKですが、中に調べてみると、少し手動でソースコードを修正する必要があります。mecab-rubyのソースコードはgoogle driverに置いてあるので、windowsOSとLinuxOSのdownload　address毎日更新する必要がありますので、使うときにご注意ください。（もっとよい方法が出るまで、一応私はできるだけ毎日一回更新します。）

このツールを実行した時、ruby自身による正規表現のエラーを特定し、解決しました。

I'm uploaded it in docker hub. If you want to try, please click this:
https://hub.docker.com/r/mak03/hyponymy-1.0/


予想の最低スペックは

memory: 16G

HDD: 100G
