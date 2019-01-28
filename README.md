# 概要
FargateをTerraformを通して使ってみる勉強用リポジトリ。

# やってみたこと
* 下記の記事でやってみたことを全てTerraform化してみる
  * [Fargateで自作したコンテナイメージを動かしてみる](https://qiita.com/yumatsud/items/0acad37d10a6782ecec8)
  * [AWS CodeBuild+Amazon ECRを試してみる](https://qiita.com/yumatsud/items/309c49556b2ac8308a59)
  * [AWS CodePipelineを使ってAWS CodeBuildでビルドしFargateにデプロイしてみる(下書き)](https://qiita.com/drafts/6e0ab4bc8444f2211271)
* 使用するアプリケーションは [kotlinwebflux](https://github.com/beta-yumatsud/kotlinwebflux) でこちらをビルド・デプロイまでやってみる
* プラスアルファとしては最終デプロイはSNSの承認的な感じ

# 参考文献
* [ECS with ALB example](https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/ecs-alb)
* ECS Resources
  * [aws_ecs_cluster](https://www.terraform.io/docs/providers/aws/r/ecs_cluster.html)
  * [aws_ecs_service](https://www.terraform.io/docs/providers/aws/r/ecs_service.html)
  * [aws_ecs_task_definition](https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html)
* Data Source
  * [aws_ecs_cluster](https://www.terraform.io/docs/providers/aws/d/ecs_cluster.html)
  * [aws_ecs_container_definition](https://www.terraform.io/docs/providers/aws/d/ecs_container_definition.html)
  * [aws_ecs_service](https://www.terraform.io/docs/providers/aws/d/ecs_service.html)
  * [aws_ecs_task_definition](https://www.terraform.io/docs/providers/aws/d/ecs_task_definition.html)
* [Terraformにおけるディレクトリ構造のベストプラクティス](https://dev.classmethod.jp/devops/directory-layout-bestpractice-in-terraform/)
