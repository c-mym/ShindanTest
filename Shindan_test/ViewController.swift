//
//  ViewController.swift
//  Shindan_test
//
//  Created by kagai on 2019/05/17.
//  Copyright © 2019 kagai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //ラベル
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var label1: UILabel!
    //ボタン
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    //問題の出題数&研究室数　14
    var randam = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] //研究室数+1　[1]からランダムで質問番号が入る
    //質問配列
    var questionList = [[String]]() /*２次元配列の初期化：質問内容と解答時の加点が入る*/
    var answerScore = [Int](repeating: 0, count: 15) /*得点を格納する１次元配列の初期化 研究室数+1*/
    var cnt = 1 //質問カウント変数(1から)
    var indexList = [0,0,0] //最大3つのindexを入れる
    var notEmpty = 0 //スコアが全研究室0でないとき1になる
    var numArray = [1,2,3,4,5,6,7,8,9,10,11,12,13,14] //番号が振り分けられた配列
    //プログレスバー
    var progressView:UIProgressView!
    var progress:Float = 1/14
    //結果画面のID
    var resultview = 1
    
    //画面ロード時
    override func viewDidLoad() {
        super.viewDidLoad()
        //ボタンの同時押しを禁止
        button1.isExclusiveTouch = true
        button2.isExclusiveTouch = true
        //ボタン設定
        button1.layer.cornerRadius = 5.0
        button1.layer.borderWidth = 1.0
        button1.layer.borderColor = UIColor.red.cgColor
        button2.layer.cornerRadius = 5.0
        button2.layer.borderWidth = 1.0
        button2.layer.borderColor = UIColor.blue.cgColor
        /// プログレスバー表示
        progressView = UIProgressView(frame: CGRect(x:0,y:UIScreen.main.bounds.height,width:UIScreen.main.bounds.width,height:0))
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 30.0)
        progressView.progressTintColor = .darkGray
        progressView.setProgress(progress, animated: true)
        view.addSubview(progressView)
        //ファイルの読み込み
        var csvLines = [String]()
        //ファイル（dataList.csv）のパス設定（ファイルの存在確認）
        guard let path = Bundle.main.path(forResource:"dataList", ofType:"csv") else {
            print("csvファイルがないよ")
            return
        }
        //ファイル（dataList.csv）から一行ずつ読み込み内容を文字列としてcsvLines配列に格納
        do {
            let csvString = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            csvLines = csvString.components(separatedBy: .newlines)
            csvLines.removeLast()
        } catch let error as NSError {
            print("エラー: \(error)")
            return
        }
        //print(csvLines.count) /*問題数＋１が行数として得られる*/
        //csvLines配列に格納された文字列をカンマで分割し２次元配列としてquestionListに格納
        //一次元目の要素数が質問数＋１、二次元目の要素数が研究室数＋１に相当
        for questionData in csvLines {
            let questionDetail = questionData.components(separatedBy: ",")
            questionList.append(questionDetail)
        }
        //乱数を取得
        createRandam()
        //質問表示
        showQuestion()
    }
    //乱数取得
    func createRandam(){ //質問リストから質問を決定
        for i in 1...14{ //randam[1]から入れていく
            let ii = (5*(i-1)+1)
            randam[i] = Int(arc4random_uniform(UInt32((5*i)-ii))+UInt32(ii))
        }
        /*上記処理の中身
        randam[1] = Int(arc4random_uniform(5)+1)//質問リスト1~5の範囲(datalist2行目〜6行目)
        randam[2] = Int(arc4random_uniform(10 - 6)+6)//6~10の範囲
        ・・・
        randam[14] = Int(arc4random_uniform(70 - 66)+66)//66~70の範囲
        */
        print("質問番号一覧 = " ,randam)
    }
    //質問表示
    func showQuestion(){
        print("cnt:\(cnt)")
        //質問表示
        label1.text = questionList[randam[cnt]][0]
        label1.font = UIFont.systemFont(ofSize: 24)
        print("質問番号:\(randam[cnt])")
        //改行させる
        label1.numberOfLines = 0
    }
    //プログレスバー更新
    func progressBar(a:Int){
        if(a == 1){
            progress += 1/14
            progressView.setProgress(progress, animated: true)
        }else{
            self.progress = 1/14
            self.progressView.progress = self.progress
        }
    }
    //「はい」ボタンタップ時の処理
    @IBAction func button_yes() {
        notEmpty = 1
        //研究室ごとにポイント加算
        for i in 1...14{
            answerScore[i]+=Int(questionList[randam[cnt]][i])!
        }
        scoreCalculation()//スコア計算
    }
    //「いいえ」ボタンタップ時の処理
    @IBAction func button_no() {
        scoreCalculation()//スコア計算
    }
    //スコア計算
    func scoreCalculation () {
        print("スコア:\(answerScore)")
        progressBar(a: 1);
        if(cnt < 14){ //全ての質問が表示されるまで
            cnt += 1
            showQuestion()
        }else{ //全ての質問に答え終えた
            cnt = 1 //カウント変数を初期化
            if(notEmpty == 1){//「はい」がいくつか選ばれスコアに差があるとき
                //最大3つの研究室を取得
                for i in 0...2{
                    //得点が最大値となるもっとも若い要素番号を取り出す
                    if let firstIndex = answerScore.firstIndex(of: answerScore.max()!) {
                     answerScore[firstIndex] = -1*answerScore[firstIndex]
                        indexList[i] = firstIndex
                        print("\(i+1)位 \(questionList[0][firstIndex]) \(answerScore)")
                    }
                }
                notEmpty = 0
            }
            else{//全て「いいえ」が選ばれた時表示される研究室が同じになるためランダムで表示
                for i in 0 ..< numArray.count{//番号を振り分けている配列の中身をシャッフル
                    let r = Int(arc4random_uniform(UInt32(numArray.count)))
                    numArray.swapAt(i, r)
                }
                for i in 0...2{
                    indexList[i] = numArray[i]
                }
            }
            answerScore = [Int](repeating: 0, count: 15) //スコアを初期化
            showResult() //結果画面表示
        }
    }
    //結果画面表示
    func showResult(){
        // スクリーンのサイズを取得
        let screenWidth:CGFloat = view.frame.size.width
        //UIScrollViewのインスタンス作成
        let scrollView = UIScrollView()
        //scrollViewの大きさを設定。
        scrollView.frame = self.view.frame
        //背景色を設定
        scrollView.backgroundColor = UIColor.white
        // スクロールバーの見た目と余白
        scrollView.indicatorStyle = .black
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 0)
        //viewのID付け
        scrollView.tag = resultview
        //最初にスクロールバーを表示させる
        scrollView.flashScrollIndicators()
        //ラベル
        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        label1.text = "あなたにぴったりの研究室は..."
        label1.textColor = UIColor.white
        label1.backgroundColor = UIColor.systemBlue
        label1.font = UIFont.systemFont(ofSize: 24)
        label1.textAlignment = .center
        scrollView.addSubview(label1)
        var imageEndY = Float(0.0)//画像下端のy座標取得用
        //研究室情報を表示
        for i in 0...2{
            if(indexList[i] != 0){
                //研究室名
                let label2 = UILabel(frame: CGRect(x: 0, y: Int(30+imageEndY), width: Int(UIScreen.main.bounds.size.width), height: 100))
                label2.text = questionList[0][indexList[i]]
                label2.font = UIFont.systemFont(ofSize: 28)
                scrollView.addSubview(label2)
                //研究室情報
                let label3 = UILabel(frame: CGRect(x:0, y:Int(100+imageEndY), width:Int(UIScreen.main.bounds.size.width), height:100))
                let kenkyushituInfo = getInfo(i: indexList[i])
                label3.text = kenkyushituInfo
                //自動で改行
                label3.numberOfLines = 0
                label3.sizeToFit()
                label3.lineBreakMode = NSLineBreakMode.byCharWrapping
                scrollView.addSubview(label3)
                //研究室画像
                let kenkyushituImage = questionList[0][indexList[i]]
                // UIImage インスタンスの生成
                let image1:UIImage = UIImage(named:kenkyushituImage)!
                // UIImageView 初期化
                let imageView1 = UIImageView(image:image1)
                // 画像の縦横サイズを取得
                let imgWidth1:CGFloat = image1.size.width
                let imgHeight1:CGFloat = image1.size.height
                // 画像サイズをスクリーン幅に合わせる
                let scale1:CGFloat = screenWidth / imgWidth1
                let rect1:CGRect = CGRect(x: 0, y:Int(180+imageEndY), width:Int(imgWidth1*scale1), height:Int(imgHeight1*scale1))
                // ImageView frame をCGRectで作った矩形に合わせる
                imageView1.frame = rect1;
                imageEndY = Float(imageView1.frame.origin.y+imageView1.frame.size.height) //画像下端のy座標
                // UIImageViewのインスタンスをビューに追加
                scrollView.addSubview(imageView1)
            }else{
                break
            }
        }
        //終了ボタン
        // UIButtonのインスタンスを作成する
        let button = UIButton(type: UIButton.ButtonType.system)
        // ボタンを押した時に実行するメソッドを指定
        button.addTarget(self, action: #selector(buttonEvent(_:)), for: UIControl.Event.touchUpInside)
        // ラベルを設定する
        button.setTitle("終了",for: UIControl.State.normal)
        // サイズを決める
        button.frame = CGRect(x: 0, y: 0,width: 81, height: 50)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        // 位置を決める
        button.layer.position = CGPoint(x: self.view.frame.width/2, y: CGFloat(imageEndY+60))
        // viewに追加する
        scrollView.addSubview(button)
        //スクロール領域の設定
        scrollView.contentSize = CGSize(width:0, height:Int(imageEndY+100))
        //scrollViewをviewのSubViewとして追加
        self.view.addSubview(scrollView)
    }
    // 終了ボタンが押された時に呼ばれるメソッド
    @objc func buttonEvent(_ sender: UIButton) {
        //UIAlertControllerクラスのインスタンスを生成
        //タイトル, メッセージ, Alertのスタイルを指定する
        //第3引数のpreferredStyleでアラートの表示スタイルを指定する
        let alert: UIAlertController = UIAlertController(title: "", message: "終了してもいいですか？", preferredStyle:  UIAlertController.Style.alert)
        //Actionの設定
        //Action初期化時にタイトル, スタイル, 押された時に実行されるハンドラを指定する
        //第3引数のUIAlertActionStyleでボタンのスタイルを指定する
        //OKボタン
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            // タグを利用してviewを消す
            let sv = self.view.viewWithTag(self.resultview)
            sv?.removeFromSuperview()
            //乱数を取得
            self.createRandam()
            //質問表示
            self.showQuestion()
            //プログレスバー初期化
            self.progressBar(a: 0)
        })
        //キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
        })
        //UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        //Alertを表示
        present(alert, animated: true, completion: nil)

    }
    //研究室情報を取得
    func getInfo(i:Int) -> String{
        var str = " "
        if(i == 1){
            str = "〜超高速次世代移動無線通信ネットワーク〜\n 超高速通信が可能な携帯電話ネットワークの構築を目指して、遅れて届く電波の干渉や送信電力の増大という課題を克服するために、計算機シミュレーションやハードウェア実験を行っています。"
        }
        else if(i == 2){
            str = "〜人工衛星や惑星探査機で宇宙科学に挑む〜\n 惑星や人工衛星に超音速で吹き付ける太陽風プラズマは、オーロラをはじめとする多彩な電磁現象を宇宙空間にもたらしています。人工衛星や惑星探査機によって得られたデータを解析し、宇宙の謎に挑んでいます。"
        }
        else if(i == 3){
            str = "〜新しい光通信システムの技術を開発する〜\n 増大する情報伝送量に対応するには、１本の光ファイバで大量の情報を運ぶ必要があります。さまざまな波長の光を１本の光ファイバで同時に運び、その一部だけを取り出したり切り替えたりできる技術を研究しています。"
        }
        else if(i == 4){
            str = "〜大容量伝送を目指したマイクロ波ミリ波技術〜\n テレビやラジオ、携帯電話など、多くの情報通信機器はマイクロ波帯の電波を使っています。\"独創性\"をキーワードに、マイクロ波ミリ波帯のアンテナ、伝送回路、デバイスやこれらを使った伝送技術を開発しています。"
        }
        else if(i == 5){
            str = "〜地球環境を見守るレーザー光を開発〜\n 温暖化対策や気象予測、防災などの分野では、より高精度な環境情報が求められています。風向・風速や二酸化炭素濃度などの空間分布情報を計測するために必要な新しいレーザー技術の研究・開発を行っています。"
        }
        else if(i == 6){
            str = "〜「情報」を「動き」に変えるセンサやモータの開発〜\n 情報を動きに変えることのできるモータ、動きを情報に変換するセンサ、どちらもロボットなど近未来の生活に活きる技術です。微小で高速な振動、つまり超音波を用いた微小なモータやセンサを開発しています。"
        }
        else if(i == 7){
            str = "〜記憶に残る声から発話者の情報を〜\n 声には話者特有の情報が含まれています。この個人性情報は、声を聴いた人にも記憶として残ります。記憶から有用な情報を引き出すため、法科学（犯罪科学）の見地から音声に関する研究を進めています。"
        }
        else if(i == 8){
            str = "〜ソフト・ハード両面からマイクロプロセッサを考える〜\n マイクロプロセッサはコンピュータの心臓部であり、最近では消費電力等の制約の厳しい家電などにも組み込まれています。それらのプロセッサの高性能化を目指し、ソフトとハードの両面から取り組んでいます。"
        }
        else if(i == 9){
            str = "〜自然物・自然現象をリアルなCGで表現〜\n 山岳地形や鳥の飛翔など、自然物・現象をCGでリアルに表現するための研究を行います。複雑な形状や動作をいかに少ない計算量で再現するかが課題で、景観シミュレーションなどに応用が期待される研究です。"
        }
        else if(i == 10){
            str = "〜人の認知を理解し、知的なシステムを構築する〜\n 人間の理解と情報システムの高度化に関心があります。対面対話の分析、オンラインでのコミュニケーションの分析、マルチメディアや地域情報アクセス手法の開発、対話システムの開発などを行っています。"
        }
        else if(i == 11){
            str = "〜ノア衛星の画像を解析し環境評価法の確立を〜\n 約20年にわたって蓄積されているノア衛星の画像を解析し、北アジア地域の環境研究を行います。画像処理をはじめとする情報通信分野の技術を駆使し、地球環境評価方法の確立を目指します。"
        }
        else if(i == 12){
            str = "〜誰もが安心して使えるネットワークを〜\n コンピュータからの管理情報の確実かつ効率的な収集法やネットワークの監視技術などについて研究します。ますます複雑になるネットワークを誰もが安心して使えるものにすることを目指しています。"
        }
        else if(i == 13){
            str = "〜データベースと電子機器をネットワークで結ぶ〜\n ネットワークに対応した電子機器の制御システムを開発し、データベースと融合したシステムの実現を目標としています。ネットワークからハードウェアまでの幅広い分野が研究の対象です。"
        }
        else if(i == 14){
            str = "〜人間の認知活動を応用したシステムの開発〜\n 高度情報化システムを利用する人間の認知活動を脳科学の手法を用いて計測し、その結果を、安全で便利なシステムの開発に応用する研究を行います。人間の行動や脳活動の計測・解析に実践的に取り組みます。"
        }
        return str
    }
}
