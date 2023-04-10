---
title: The-Cathedral-the-Bazaar-zh
date: 2022-01-04 14:08:23
tags: [reproduced,read]
---

教堂与市集

<!-- more -->

## 第一章 教堂与市集

Linux 打破了许多软件开发的传统，这个世界级的操作系统在五年前（1991 年）仅仅靠着如丝般的互联网，神奇地联合了散布在全世界数以千计兼职的玩家们来开发它，谁曾料到会发生这样的事情呢？

我当然也没料到，Linux 出现在我电脑屏幕是在 1993 年初，当时我埋首于 UNIX 及开源的软件开发已有十年，1980 年代中期，我是 GNU [^1] 项目首批的贡献者之一，我写过许多开源的软件放到网络上供人使用，也曾独立或协同开发好几个程序（nethack，Emacs 的 VC 和 GUD 功能，xlife，...等等），这些程序到今天仍广泛地为人所用，我想我知道这是怎么办到的。

Linux 扭转了许多我认为我已知道的观念。多年来我一直宣扬使用小工具集、快速原型及快速开发的 UNIX 福音。但我也相信对于有一定复杂度的程序必需使用集中和有经验的方法来开发，我相信最重要的软件（操作系统以及庞大的工具程序如 Emacs）必须如建造一座教堂般，由个别的高手或一小群专家在光辉的孤立中小心翼翼地精雕细琢，时机未到之前，不会发布测试版。

`Linus Torvald`[^2] 的软件开发风格（尽早并经常发布新版本，授权每一件作者可以委托的事，不拒绝几乎到混乱程度的程序）的出现如同一个惊奇，没有令人肃然起敬的教堂，甚至 Linux 的同好们似乎组成了一个有不同流程和不同方式的大市集（Linux 的档案网站就是它适切的象征，每个人都服从着自由的规则），以这个风格开发出来的 Linux 既一致又稳定，表面上看来真是一连串的奇迹。

市集模式似乎是可行的，并且运作得很好，这个事实带来了相当的震憾。当以我的方法去认知时，我除了努力做好个人的项目，并也试着去了解为什么在Linux的世界，不但没有因为浑沌不清而四分五裂，反而以教堂建造者几乎想像不到的速度在茁壮。

直到 1996 年年中，我想我才开始了解这一件事。我得到了一个绝佳的机会来试验我的理论，这个机会是一个开源形式的项目，正好可以试用市集模式来开发，所以我做了这个项目，而且更有意义的是它成功了。

接下来在这篇文章中我将陈述这个项目的故事，并且以它为例提出关于有效地利用开源模式来开发软件的格言，这些法则并非都是我在 Linux 中第一次学到，但我们可以看到 Linux 的世界是怎么赋予它们特别的意义。如果我是对的，那么这些格言将会帮你真确地了解是什么促成 Linux 社群成为好软件的原创者，并且帮助你变得更具生产力。

## 第二章 信一定要寄到

自 1993 年起，我一直担任一家提供免费上线的小型 ISP 的技术人员，这家 ISP 叫做 County InterLink（CCIL），位于宾夕凡尼亚州的 West Chester。（我本身参与捐款设立 CCIL，并写了我们独一无二的多人布告栏软件，你可以用 telnet 连线至 [locke.ccil.org](telnet://locke.ccil.org) 一探究竟。目前它共有三十条线，可提供近三千位的用户上网。）这个工作让我可以一天二十四小时透过 CCIL 56K 的线路上网。事实上，我的确非常需要它！

因此我必须常常利用便捷的互联网电子邮件，但由于一些复杂的原因，使得我家里的机器（snark.thyrsus.com）要以 SLIP 协议连上 CCIL 有所困难。最后我还是做到了，但我马上发觉我必须周期性地以 telnet 连上 locke 来检查我是否有新信件，这实在是一件烦人的事。我想要的是︰我的邮件可以被送到 snark，而且送达时会通知我，然后我可以用 snark 上的工具程序来处理这些邮件。

网络原生的 SMTP（Simple Mail Transfer Protocol）转信功能在这里帮不上忙，因为我个人的机器并不是时时都和网络连结着而且它也没有固定的 IP 位址。我所需要的程序是这样的︰它可以间歇地连线把我的电子邮件都抓回来并放在我的机器。我知道有这样的程序，它们大部份都使用一个简单的网络应用协议叫 POP（Post Office Protocol）。目前 POP 是最通用的邮件客户端协议，但当时我使用的邮件读取端却没有这个协议。

我需要一个支持 POP3 的客户端程序。所以我到网络上搜寻之后找到一个。其实我找到了三或四个这样的程序。我使用了其中一个一阵子，但是它少了一个重要的特性，就是精巧地处理抓回来信件附件的地址，以使收件人能回复信件至正确的网址。

这个问题是这样的︰假设 locke 上有一个叫做 joe 的用户寄信给我，当我把信抓到 snark 上并回信给 joe 时，我的送信程序会傻呼呼地试着把这封回信送给根本就不存在 snark 上的用户 joe。所以我必须动手编辑回信的网址即加上 <@ccil.org>，很快地这变成了一件颇痛苦的事情。

很明显的这是电脑应该帮我做的，可是现有的 POP 客户端程序却没有任何一支知道要这么做。这使我们学会了第一课︰

**格言1︰好软件都是起源于程序开发者要解决切身之痛。**

也许这已是众所皆知（不是有句着名的谚语叫︰「需求为发明之母」吗？），但有多少软件开发者为了薪水，把时间都耗在写他们既不需要也不喜爱的程序上呢？然而这样的事不会发生在 Linux 的世界 ―― 这也许可以解释为什么由 Linux 社群们开发出来的软件的平均水准都这么高。

所以，我是否该立即如抓狂般地投入写作一个新的 POP3 客户端的程序来和既有的一较高下？并不如你所想的，我仔细地检视我手上已握有的 POP 工具程序，看看那一个最符合我的需要，因为︰

**格言2︰优秀的程序师知道要写程序，伟大的程序师知道要改写（和重复利用）程序。**

我并非在宣称我是一个伟大的程序师，但我愿去效法。伟大的程序师还有一项重要的特色是制造着偷懒的办法，他们认为人们争取最好的成绩并不是为了努力的过程，而是为了最后的结果。更何况由一个部份可行的解决方法开始总比什么都没有容易得多。

举例来说，[Linus Torvalds](http://www.tuxedo.org/~esr/faqs/linus) 当初写 Linux 的核心程序时也不是从零开始，他是由借重 Minix 的程序和构想开始的（Minix 是一个像 UNIX 的小型操作系统，它在386机器上执行），然而到最后原来属于 Minix 的代码不是被移出就是被改写 ―― 尽管如此，Minix 的代码毕竟曾存在于 Linux 中，并且曾为尚未茁壮的 Linux 提供一个骨架，最后终于诞生了 Linux。

为仿效这样的精神，我开始找寻一个现有而且写得有条理的 POP 工具程序，来作为我开发新程序的基础。

在 UNIX 的世界中，原始代码共享的传统让我们可以很容易地重复利用代码，这也是为什么 GNU 项目要选择 UNIX 作为它开发的平台，UNIX 操作系统本身几乎没做什么保留，Linux 的世界也遵行着这个传统，到接近它技术极限的地步，它供人运用的开源程序，有天文数字般地多，所以在 Linux 已有的资源中找到一个足够好的程序要比其他的操作系统容易。

而我也的确找到了，连我先前的搜寻再加上这一次总共有九个程序候选 ―― fetchpop、PopTart、get-mail、gwpop、pimp、pop-perl、popc、popmail 及 upop。我首先选择 Seung-Hong Oh 写的 fetchpop 作为出发点，我加入了我要的「重写邮件头」功能，并且作了多处的改善。原作者同意将这些纳入 fetchpop 的 1.9 版。

几个星期之后，我缓缓地读着 Carl Harris 写的 popclient 的源代码，并且发现了一个问题︰虽然 fetchpop 有一些好的初始想法（如它的伺服程序模式），但它只能处理 POP3 的协议，而且它的原始程序只有业余的水准（Seung-Hong 是个聪明的程序设计师，但当时经验不够老道）。而 Carl 写的代码就比较好，具相当的职业水准和稳固性，但他的程序缺乏了许多重要的特色，如 fetchpop 中巧妙的实践（包括我加入的部份）。

要换还是不换呢？假如我选择换的话，那么换到一个较好的开发基础所要付出的代价就是要丢掉我已经写好的代码。

事实上我选择换的动机是为了能支持多种 post-office 的协议，虽然 POP3 最广为人采用，但它却不是唯一可用的协议。Fetchpop 和其他同类的程序并不支持 POP2、RPOP 或 APOP，而我早先有一个概略的想法（只是为了有趣）︰加入[IMAP](http://www.imap.org/)（Internet Message Access Protocol，最新最强的 post-office 协议）协议的支持。

一个更理论性的理由让我觉得换到新的开发基础是个好主意，这个理论是早在 Linux 出现前，我就已经学会了︰

**格言3︰「计划好如何舍弃一条路吧，你迟早会想尽办法这么做的。」**（Fred Brooks，《人月神话》，第十一章）

否则，计划走另一条路吧。针对一个问题，在尚未实践出第一个解法前，你通常并不真正了解这个问题。也许第二次的时候你才能充分了解怎么做才对，所以即使你想做对一件事，但起码你要准备从第一次做起。[^3]

我告诉我自己︰修改 fetchpop 是第一次。所以我换到 Carl Harris 的 popclient 继续开发。

当 1996 年 6 月 25 日我送给 Carl Harris 我第一次对 popclient 所做的修正后，我才晓得他已经对这个程序没兴趣了。原来的代码乏人照料已有一段时间，还包括一些次要的错误。有许多修正要做，很快的我们两人都同意由我接手整个程序是合理的一件事。

在我不经意间，这个项目的规模扩大了，我不再只注意现在的 popclient 要修补那些次要的部分，而是要接下维护整个整程序，在我脑海曾浮现许多主意，我想这可以引导我改变 popclient 的主要部分。

在鼓励分享代码的软件文化下，一个项目以这样自然的方式演进。我表现出︰

**格言4︰抱持正确的态度，就会发现有趣的问题。**

但 Carl Harris 的态度更为重要，他懂得︰

**格言5︰当你对一个问题不再感兴趣时，你最后的责任就是找位能胜任的接棒人。**

虽然 Carl 和我没讨论这些，但我们却有一个共同的目标就是对这个问题写出最好的解法。现在唯一的问题只剩︰证明我是个可信赖的人，而我已经做到，所以他便欣然地把这个程序交给了我。我希望这个项目在我手中能变得更好。

## 第三章 拥有用户的重要

我继承了 popclient，更重要的是我也继承了它的用户。拥有用户是很棒的一件事，并不是因为这展现出你在解决他们的问题，或是你在做好事。而是好好地培养用户，他们可以变成协同开发者。

UNIX 的传统中有一种力量，那就是许多用户同时也是程序高手，Linux 促使这变成一件非常愉快的事。这是因为源代码是公开的，所以用户可以变成有影响力的高手，这对缩短除错的时间实在太有助益了。只要你给一点掌声，用户们会帮你诊断问题，建议需要修正的地方，以及改进代码，这比你自己一个人包下全部的事要快许多。

**格言6︰把你的用户视为协同开发人，可以让你伤最少的脑筋而做到源代码的快速改善、程序的高效除错。**

这种效应所造成的影响力很容易就被低估，事实上，开源世界的所有人，几乎都严重低估了因用户增多而产生用以对抗系统复杂度的力量，直到 Linus Torvalds 明白地揭露了这一点。

其实我认为 Linus 在技术上最聪明和最重大的贡献并不在于写出 Linux 的核心程序，而在于发明 Linux 的开发模式。在一次和他的会面中，我提出了这点见解，他微笑着，并重复他常说的一句话︰「基本上我是一个非常懒的人，因其他人在 Linux 上真正的努力，而感到与有荣焉。」懒惰就像狐狸一样地精明，或者就如同 Rober Heinlein 曾说︰「因为太懒所以成功了。」

回顾过去的例子，在 GNU Emacs 的 Lisp 程序库及其 Lisp 代码的资源库中，我们可以看到 Linux 模式所用的方法和所得的成功。相对于 Emacs 中用 C 语言写的核心部分及自由软件基金会其他的工具（这都是以建造教堂的模式开发），Emacs Lisp 代码库非常地用户导向并且更新很快，好的点子和原型在最后成熟稳定前常常都已重写过三或四次，藉由互联网而来的非紧密合作进行得很频繁，就像 Linux 一样。

我在还没写作 fetchmail 前，最成功的杰作大概要算是 Emacs 的 VC（version control）功能了，这项项目进行时，我用像 Linux 一样的合作模式，用 email 和其他三位作者互相联系，到今天为止，我只见过其中一位（他就是 Richard Stallman，Emacs 的作者以及[自由软件基金会](http://www.fsf.org)的创办人）。Emacs 的 VC 功能是作为 SCCS，RCS 及后来的 CVS 的前端处理，提供版本控制功能「按一下」的操作法，这是由某位仁兄撰写的小而有力的 sccs.el 功能改良而来，VC 功能的开发相当成功，这是因为 Emacs 用的 Lisp 程序可以快速地经历「发布 ―― 测试 ―― 改良」，而不像 Emacs 本身核心的开发那样缓慢。

Emacs 的故事并非特例。有其他的软件结合了双层的架构与双层的用户社区，前者采用教堂模式开发核心，后者采用市集模式开发工具箱。例如 MATLAB，一个商业的资料分析与视觉化工具程序。MATLAB 与其他类似结构的产品都指出，发酵与创新都在开放的部份发生，在那里各种社群都能够修补这些成果。

## 第四章 尽早发布，经常发布新版本

尽早，经常发布新版本是 Linux 开发模式中非常重要的一环。过去，大部份的程序开发者（包括我）认为这个策略对较大型的项目是不好的，因为早期的版本几乎可以定义为多错的版本，我们并不想把用户的耐心消磨殆尽。

这个过去的信念加强了软件的开发要用建造教堂的方式的想法。假如我们极欲强调的目标是让用户在软件中发现最少的错误，那你何不每半年（或更长）才发布一个新版本，并且在开发新版本的期间，卖力地除错而累得像条狗似的。Emacs 的核心部分（用 C 语言写的）就是用这种方式开发的，但它的 Lisp 程序库就不是。因为 Emacs 的 Lisp 资源库不在自由软件基金会的管辖内，你可以在其中找到新开发的 Lisp 程序使用，而不受限于 Emacs 的发布周期[^4]。

在 Emacs 的 Lisp 程序库中，最重要的一个来源是俄亥俄州的 elisp 资源库，它先前的精神就已经具有今日大规模 Linux 资源库的特色，但当时我们之中却很少有人思考过我们到底做了什么，甚至想过我们已对自由软件基金会的「建造教堂」的开发模式提出质疑。1992 年左右，我很认真地要把俄亥俄州 elisp 资源库中许多程序加入 Emacs 正式的 Lisp 程序库中，但却遭遇到官方的阻碍而失败了。

但一年之后，Linux 已受到四方的瞩目，也带来不同而且更健康的观点，Linus 的开放性发展策略和「建造教堂」非常不同。当时 Linux 的两大资源库 sunsite 和 tsx-11 正在萌芽，有许多版本在交流着，Linux 核心系统发布新版本的频繁程度前所未有。

Linus 以最有效的方法，视用户为协同开发者︰

**格言7︰尽早，经常发布新版本，并且倾听用户的意见。**

Linus 的创新并不完全在此（这在 UNIX 世界是行之有年的传统了），而在于提高这个做法效力的层次，使其能匹配他在开发的系统的复杂度。早期在 1991 年左右，许多人都知道他一天内发布一次以上 Linux 核心程序的新版本。因为他善用互联网和协同开发者们合作更胜于其他人。

他能我也能吗？还是只有像他这样的天才才办得到？

我并不认为如此，虽然 Linus 是一位很厉害的高手（在我们之间，有多少人能够完整地写出一个具有商品品质的操作系统核心呢？），但 Linux 并不是一个空前跃进的观念，Linus 也并非（或者说至少目前还不是）如 Richard Stallman 或 James Cosling（NeWS 和 Java 的创始者）这样的天才创新者，而我个人认为他是一位天才工程师，他有避免程序错误及避免程序开发掉入死胡同的第六感，和找到两点间最省力路径的技巧。事实上，整个 Linux 的设计中，我们可以看到 Linus 表现出的品质和他保守而简单的设计取向。

承上所说，如果快速地发布新版本和彻底地善用互联网媒介不是突然冒出，而是以 Linus 天才工程师洞见所得的最省力路径，那么他把互联网的什么功用发挥到最大？

其实问题的本身已反应出答案，Linus 让 Linux 的高手和用户们经常感觉刺激和有收获 ―― 感觉刺激是因协助开发 Linux 得到自我满足，感觉有收获是因经常（甚至每天）进步的 Linux 帮助他们把工作做得更好。

Linus 想直接将投入除错和开发的「人-时」（person-hours）数加到最大，即使要付出的代价是代码的不稳定，或是因一些程序错误被证实无法追踪而吓走原有的用户。Linus 会如此做是因为他相信︰

**格言8︰以足够多的 beta 版测试者和协同开发者做基础，几乎程序中的每一个问题都可以很快地找出来，并且对某些人而言，针对发现的问题的解决方法是显而易见的。**

或者用比较不那么正式的说法︰「足够多的人来看程序，所有的错误都变得浅显」，我将此命名为「Linus法则」。

我原本的论述是︰「某些问题对某些人而言是容易解决的」，但Linus有不同的意见︰「了解并解决问题的人不一定是第一个发现问题的人」，他说︰「有些人发现问题，有些人解决问题，我愿正式强调 ―― 发现问题是较大的挑战。」而在 Linux 的世界，发现问题和解决问题的速度都很快。

对「Linus法则」来说，我想这就是教堂模式和市集模式最主要的不同，以教堂建造者的观点来看程序开发，程序错误和相关问题难以处理，并隐伏在深处，需要数个月的工夫仔细察看来找到它们，而这对程序开发者的自信少有加许。开发的期间越长，一旦经冗长等待的新版本发布后不如预期完美，用户的失望也越大。

另一方面就市集开发模式的观点来看，它假设程序错误都是显而易见的，或者说至少在上千位渴望新版的协同开发者面前，程序错误很快地都变得浅显，因此经常发布新版本是为了获得更多的指正，以及避免偶尔笨拙的修补。

以上已足够说明「Linus法则」。如果「Linus法则」是假的，那么任何像 Linux 核心程序这样复杂的系统，并且拥有像 Linux 核心程序这么多的高手在开发，早就因沟通不良及未被发现的程序错误而崩塌。反过来说如果「Linus法则」是真的，那正可解释为什么相对地 Linux 比较没有程序错误。

也许「Linus法则」并不是一个惊奇，社会学家多年前发现，在一群素质相同的观察家中，他们共同做出的预测要比其中任一位单独所做的要来得可信。这被称为「Delphi[^5]效应」。可见 Linus 只是把「Delphi效应」用在开发操作系统时对程序的除错上，所以「Delphi效应」能够克服开发系统的复杂度，即使复杂如操作系统核心[^6]。

「Linus法则」也可称之为「程序除错可并行处理」。虽然多位程序除错者在除错时需要和一些程序开发者沟通协调，但是程序除错者彼此间却不需如此。所以增加程序除错者并不会像增加程序开发者那样，多出平方倍的复杂度和管理成本。

理论上造成程序除错效率减低的原因是多位除错者重复同一件工作，就实际的情形而言，在 Linux 的世界中几乎不会发生这样的状况。「尽早，经常发布新版本」这个策略使得程序错误的修补回馈得很快，借此将除错者重复同一件工作的机会减至最低[^7]。

Brooks 曾发布过一个即席的看法︰「维护一个广为人用的程序的总成本通常是开发这个程序成本的百分之四十或更多，令人讶异的是这维护成本深受用户人数的影响，越多的用户可以发现越多的程序错误。」（这正是我所要强调的）

因为增加越多的用户，就会增加考验程序的方法，所以用户越多，发现的程序错误也越多，当用户也是协同开发者时这种效应会再被放大，每一位用户以不同的直觉，不同的分析工具，和不同的角度来标明程序错误，因为这些不同，「Delphi效应」似乎真的有作用了，在个别情况下的除错工作，也因这些不同而减少重复出力的可能。

所以，以程序开发者的眼光看来，增加更多的 beta 版测试者也许不会减少目前藏在深处的程序错误的复杂度，但可以增加某位除错者以他的工具程序找到这个程序错误的机会，而这个程序错误对这位除错者来说是浅显的。

Linus 也在这种方式上下了赌注。因为程序都会有错误，Linux 核心程序以一种特别的方式来定出版本号码，让用户可以选择要用上一个比较稳定的版本，还是选择错误风险比较高的新版来使用新功能。这个策略尚未正式为大部分的 Linux 高手所採行，但是它也显示出一个事实，就是用户可做选择使得这两种版本都更有吸引力[^8]。

## 第五章 有多少眼球驯服了复杂度

可以很明显地观察到市集模式极大地加速了除错与程序演化。另一件可以清楚明白的是，在微观上，开发者与测试者的每天活动中，市集模式如何与为何可以达到这样的成果。在本章（初版完成三年后，依据开发者多次亲身体验过的洞察力），我们将仔细的检查它的实际机制。非技术性倾向的读者可以略过这一章，直接跳到下一章去。

一个关键点是，为何没有源代码意识的用户所报告的错不会太有用。没有源代码意识的用户倾向报告表面上的问题，他们把自己的使用环境视为理所当然，所以他们会忽视重要的背景资料，报告错误时很少会包括可信赖的过程。

这里的问题是测试者与开发者对问题的视角不同，测试者由外向内看，开发者由内向外看。在封闭源代码的体系中，两者只会固守自己的角度谈论事情，因而对另一方深深的失望。

开源的体系则打破这条界线，使测试者与开发者可以站在同样的角度来讨论事情，这有高效多了。实践中，这将有巨大的差异，一者是只报告表象的症状，一者是以开发者那种以源代码为基础的角度来看问题。

大部分的时候，大多数的bug是可以由描述开发层级的特征来除错的，即使是不完整的描述。当一个 beta 测试者告诉你在那一行代码有边界的问题时，或告诉你在 X、Y 跟 Z 的情形下，有个变量有问题，指出有问题的代码通常就足够找出问题并修正它。

因此，对于 beta 测试者与核心开发者来说，有源代码意识的人对于双方都可以强化沟通与合作。换句话说，核心开发者的时间被节省了，即使是在有很多共同开发者的情形下。

另一个开源方式的特征是节省开发者的时间，而这是典型开源项目的沟通结构。上面我使用了「核心开发者」（core developer）这个字来区别项目核心（project core，通常很小；一个开发者是常见的，一到三个开发者则是很典型的）与项目圈（project halo）的 beta 测试者跟贡献者（通常有数百个）。

传统软件开发组织的根本问题是「Brooks法则」︰在落后的项目，增加越多程序员会使得项目更落后。一般的状况下，「Brooks法则」的预测是，随着开发者的人数增加，复杂度与沟通成本随着人数的平方上升，而完成的工作却只成线性上升。

「Brooks法则」依据的经验是，bug会在由不同的人编写的代码的接口上大量出现，而沟通损耗会随着项目参与人数的升高而升高。因此，问题的规模会随着开发者间的沟通路径而呈现平方上升。（精确的说，是 N x （N-1）/2，N 是开发者的数目。）

「Brooks法则」的分析建立在一个隐藏的假设基础上︰项目的沟通结构必须是完全图（complete graph），每个人都可以跟每个人沟通。但是在开源的项目中，开发者在有效平行分割的子项目中彼此很少互动；程序更改与bug报告是透过核心团体来处理的，只有在这样的小团体中，「Brooks法则」的分析才成立[^9]。

还有其它原因让源代码层级的bug报告变得有效率。事实是一个错误常常会有许多可能的症状，取决于使用的的使用状况与使用环境。这些错误是一些复杂与微妙的bug（像是内存管理错误或视窗的随意中断），也是最难被发现或靠静态分析来捕捉的，这在长期的开发中造成最多的问题。

当一个测试者发出一个尝试性的源代码层级的多症状bug报告（例如，我看来在第 1250 行代码有个窗口在做讯号处理，或你在哪里把那个缓存清空），可能会给开发者一个关键的线索来发现半打的症状，这些开发者通常因为太靠近底层代码而无法发现这样的问题。在这种案例中，很难找出可从外部看见的不正确动作是从哪个bug引起的，甚至是不可能的 ―― 但是透过经常发布，就不需要知道了。其他的合作者会迅速找出bug是否已被修正。在很多案例中，导致不正常动作的源代码层级bug将被移除，甚至在还没有被报告之前就被移除。

复杂的多症状错误，通常有很多从表面症状来的方式可以找出真正的bug。这种能让测试者与开发者找出问题的方式，可能与开发环境有关，也可能会随着时间而有无法预期的变化。实际上，当测试者或开发者追踪一个症状时，都是在程序空间的一个集合中「半随机」（semi-random）取样。bug越微妙复杂，越难找出相关的样本。

对于简单与容易复现的bug，重点在于「半」（semi）而非在「随机」（random）；debug技巧、对程序与架构的熟练都是关键。但对于复杂的bug来说，重点就是「随机」（random），这时人多比人少好 ―― 即使这些少数人是平均技巧较高的。

如果从表面的症状找出bug的难度大，像是一些无法从表面症状预测的，上述的结果会进一步增强。单一的开发者可能会以一个困难的方式来做第一次尝试，但其实也可以从简单的方式达到同样的结果。另一方面，假如很多人随着频繁的版本一起测试，可能就会有一个人可以用最简单的方式找到bug，节省了大量的时间。项目管理者将会发现，随着新版本发布，许多人一起用各种复杂方法追踪同一个bug的时代将会过去，尤其是在众人浪费太多时间之前[^10]。

## 第六章 今花非昨花？

由 Linus 行为的研究中，我们得到了一个能解释他为什么成功的理论，所以我想要在我的新项目（当然不如 Linux 内核程序复杂和雄心勃勃）中来测试这个理论。

但我做的第一件事情是大力重组和简化 popclient 的程序，Carl Harris 的实现非常扎实，可是却像许多的 C 程序员一样，含括了一种不必要的复杂，他以代码为主，数据结构为辅，因此代码看起来漂亮，但数据结构却很特殊，甚至可以说是丑陋的（至少以这位老资格 Lisp 高手的高标准而言）。

然而，我重写程序除了改良原来代码和数据结构的设计外，还有其他目的，就是把它开发到我可以完全了解，否则负责修补你不懂的程序是一件很无趣的事。

项目进行的第一个月，我简单地依循着 Carl 原来基本设计的用意，第一个重大的改变是我加入 IMAP 协议的支持，我重构原来处理协议的程序，改成一个较为通用的驱动程序再加上三个驱动它的方法表（即 POP2，POP3 和 IMAP）。这个改变阐释了一个广义的原则，特别在像 C 这种先天上未提供动态类型的程序语言，程序员们最好谨记在心︰

**格言9︰聪明的数据结构配上笨拙的代码要比相反的组合好。**[^11]

Brooks 在《人月神话》的第九章中也说︰「光给我看你的代码，而不给我看它用的数据结构，我会一头雾水。给我看你程序的数据结构，我通常不需要再看你的代码，因为已经够明白了[^12]。」

1996 年的九月初，从零开始工作约过了六周，我开始在想是否要帮 popclient 取个新名字，毕竟 popclient 已不仅仅是单纯的 POP 协议客户端程序，但我迟疑了，因为 popclient 的设计并无真正重大的改变，我的 popclient 尚须发展出自己的特色。

当 popclient 可以把 fetchmail 抓下来的信直接转发到 SMTP 的端口时，它彻底的改变了；至于 fetchmail，我稍待会再说明。我之前说过要用这个项目来测试关于 Linus 成功的理论，也许你会问我到底要怎么做呢？我用下面几个办法︰

* 我尽早并经常发布新版本（几乎至少每十天就发布一次，甚至在开发的高峰期，一天一次）。
* 对于每一位与我讨论 fetchmail 的人，我把他们列入 beta 测试者的名单，所以名单越来越长。
* 每当我开发出新版本，一定发出像聊天般的通知给 beta 测试者名单上的人，鼓励他们一起来参与这个项目。
* 而我也总是倾听 beta 测试者的心声，询问他们对于这个程序的设计上有无意见，并且回应他们送来对程序的修补和反馈。

在采用上述的办法后，立即就得到了回报，自从这个项目开始以来，我所收到关于程序错误的报告，其品质足以令许多的程序开发者羡慕，这些报告甚至还常常附上不错的修补办法。因而我做了关键性的思考，我收到了用户的来信，得到了关于新增智慧型功能的建议。这说明了:

**格言10︰如果你视 beta 版测试者如同你最珍贵的资源，那么他们就会成为最珍贵的资源。**

Fetchmail 达到成功的方法中，有趣的是一张薄薄的 beta 版测试者名单，也就是 fetchamil 之友的名单，当我在写这个程序时，有 249 位，然后每周增加 2 到 3 位。

这张名单中的成员人数最多时几乎到达三百，不过，当我在 1997 年五月底审订这张名单时，其中的成员已经因为一个有趣的原因而开始减少，好几位告诉我他们要停止订阅「fetchmail之友」，因为他们觉得 fetchmail 已能满足他们的需求，已经不再需要收到「fetchmail之友」。也许这是成熟的市集模式项目的正常生命周期中的一部份。

## 第七章 Popclient 变成 Fetchmail

这个项目真正的转折点发生在 Harry Hochheiser 发给我他写的原型程序，这个程序会把邮件转发到客户端机器上 SMTP 的端口，我立即了解到这个特色若有稳定的实现，那么 fetchmail 中其他的邮件传递模式都可以废除了。

有几个礼拜，其实我一直在扭曲 fetchmail 而不是真的改进它，因为它使用界面的设计虽然能提供服务，但却不够高雅，并且有太多非必要的选项成为整个程序的累赘，尤其是要把取回的邮件存成邮件档或输出至屏幕的选项对我造成了相当的困扰，可是我却也说不出个所以然来。

当我思考邮件改由 SMTP 转发这个做法时，才发觉到原来的 popclient 包揽太多事了，过去它被设计成邮件转发代理（MTA）兼邮件递送代理（MDA），若藉由 SMTP 转发邮件，那它可以完全不管邮件递送，单纯地负责邮件转发，只要把邮件转给像 sendmail 这样的邮件递送程序就可以了。

在有支持 TCP/IP 通讯协议的平台，几乎可以保证第 25 号端口（SMTP用）早就在那里等了，为什么还要和设定邮件递送代理组态或设定邮件档的上锁附加模式这些问题纠缠呢？尤其这样做可以保证取回的信件看起来像发信人透过SMTP传送一样，而这正是我们想要的。

在这里给我们上了好几课，第一课是，这个透过SMTP转发的巧思是从我仿效 Linus 的方法以来所得到最大的收获，一位用户提供了绝佳的主意，而我所必须做的已经蕴涵在其中。

**格言11︰仅次于拥有好点子的是从你的用户那里识别好点子，有时候后者反而更好。**

你将会发现一件很有趣的事︰如果你很诚实并很自谦地知道你欠人多少，那么全世界都会认为你发明了全部，而且对你先提出的天才创作，也会以为你非常谦虚，这些我们可以在 Linus 身上得到印证。

（1997 年 8 月的时候，当我在 Perl 会议上发布这篇论文时，Larry Wall 坐在前排，我念到上一行时，他叫了出来，以一种复兴宗教的神情，喊著︰「兄弟，告诉他们，告诉他们吧！」，全场的听众都笑了，因为他们知道这也发生在这位 Perl 的原创者身上.）

我以同样的精神进行这个项目，经过短短几周的时间，我开始得到类似的赞美，这些赞美不只来自 popclient 的用户，也来自该得到这种赞美而却未得到的人，我保留了一些感谢函，也许当我怀疑我人生的意义为何时，可以再看看这些信。

但除些之外，这里还有两课更基础，不具政治性，更适合所有设计的一般情形︰

**格言12︰通常，最有突破性和最有创意的方案法来自于发觉自己对问题原先的观念是错误的。**

我曾试着去解一个错的问题，就是延续 popclient 既是 MTA 又是 MDA 的设计，把它开发成有各种的本地端递送模式。Fetchmail 的设计需要重新思考，应该只要单纯地做一个 MTA 程序，成为因特网正规的 SMTP 邮递路径中的一段。

当你在开发程序的过程中撞到障碍时 ―― 也就是当你发现很难想出下一步要怎么修补时，通常是反省的时候了，但不是问是否已找到正确的答案，而是我们提出正确的问题了吗？也许问题需要再重新整顿一番。

是的，于是我重新整顿了我的问题，很明显地，该做对的事有︰（1）在原来通用的驱动程序中，加入转发邮件至 SMTP 端口的功能。（2）把它作为预设模式。（3）丢弃其他递送模式的代码，尤其是递送至邮件档及递送至标准输出。

我对第（3）步迟疑了一些时候，因为担心会吓走长久以来 popclient 的用户，因为他们一直倚靠另一种递送机制，理论上他们可以立即以 .forward 档来达到同样的效果而不靠 sendmail 程序，事实上这个转换可能含糊不清。

但当我真的去做，结果证明益处极大，popclient 驱动程序中的一段可以消失了，设计也变得简单多了 ―― 不用再屈就系统的 MTA 程序及用户的邮件信箱档，也不再需要担心底层的操作系统是否支持文件锁。

而且唯一丢掉邮件的可能也不见了，如果你指定要把邮件送到某个文件而磁盘空间又满了，那么你的邮件就丢掉了，然而由 SMTP 转发信件的话，则不会发生这种事，因为 SMTP 的接收者除非将信息送达，或至少先暂存起来待会再送，才会回复成功给发信者。

并且效能也改进了（如果只跑一次，你大概不会有感觉）。另一个有意义的好处是使用说明变得更简单了。

稍后，为了要处理某些模糊的状况，如动态 SLIP，我必需让用户可以指定本地端要用哪一个 MDA 程序来送达邮件，我发现了一个更简单的方法。

这寓意是什么呢？当你可以丢掉程序中老旧的特色而又不失掉效力，那就别迟疑。Antoine de Saint-Exupery[^13]（当他还不是经典童书的作者前，他当过飞行员和飞机设计师）曾说︰

**格言13︰设计上完美，不是「没有东西能再被加入」，而是「没有东西能再被移出」。**

当你觉得做对了，那么你的代码越来越好，越来越简洁，在这个过程中，fetchmail 的设计终于和先前的 popclient 不同了，而有了自己的特点。

该是这个程序改名字的时候了，新的设计看起来比旧的 popclient 更像 sendmail，新的 popclient 和 sendmail 都是 MTA，只是 sendmail 把邮件「推」出去给 SMTP 收信程序，再送达用户，而新的 popclient 则是把邮件「拉」回来给 SMTP 收信程序，然后再送出，所以两个月后，我把它更名作「fetchmail」。

## 第八章 Fetchmail 成长了

我把 fetchmail 设计得雅洁而新颖，程序本身也跑得很好，因为我天天都在用，并且开始有一些 beta 版测试者加入，这情形使我逐渐了解，我已不再是为了可能让少数其他人能得到一些便利，而在进行用处不大的程序开发，我已经为每一位有台 UNIX 机器，上面跑 SLIP/PPP 来取得电子邮件的玩家们，写了一个真正满足他们需要的程序。

因为借 SMTP 端口转发邮件的这个特色，潜在使得 fetchmail 足以成为同领域的杀手级程序，在同类的典型程序中，它已经够资格占到适当的位置，使得其他程序不是被舍弃就是几乎被遗忘。

我认为你不该设定或计划会有这样的结果。你必须有强大的想法并全力投入，以至于之后的结果似乎是无可避免的，自然的，甚至是注定的。要追求像这样好的结果，唯一的方法就是先拥有许多的想法，或者以工程上的判断去取得别人好的想法，而在此处这个想法的利用已超出原创者的想像。

Andrew Tanenbaum 在 386 上造出了一个简单的原生 UNIX 系统，他原先的想法只是用来作为教学的工具，但 Linus Torvalds 把这个 Minix 系统的观念拓展开来，更进一步，已经超过 Andrew 当初能够想像到的开发，并且成长出一些令人赞叹的事物。我用一样的方式（虽然规模较小），由 Carl Harris 和 Herry Hocheiser 那里得到一些想法，然后把它们发扬光大。在人们的想像中，历史上的原创者都是天才，而我们两位都不是，但是大部份的科学发展和软件开发工作，完成者不是天才原创者，反而是行家们。

Linux 和 fetchmail 的成果都是一样令人兴奋，事实上这就是每一位高手追求的成功！这些成果指示我应该把标准设得高一点，把 fetchmail 发展到我所能想像的高度，我已不只是为自己的需求而写，也为其他人所需要的功能而写，并且还要同时保持程序简单和强健。

第一个加入的重大特色是「集体邮箱」的支持 ―― 这个功能可以抓下累积在同一个群组信箱中，而属于不同用户的信件，然后再分送给原来的个别收信人。

我决定加入对「集体邮箱」的支持，部分是因为有一些用户们嚷嚷着他们需要它，但主要是因为我认为它会迫使我以更通用的法则来处理邮件头的地址，并借此除去「一人一信箱」功能代码中的错误，而我的确也做到了。为了让程序能按 RFC 822[^14] 中的规定来检查信息的语法，花了我相当长的时间，不是因为规定的个别片段难以理解，而是因为它包括了成堆相互依赖的琐碎细节。

结果「集体邮箱」的支持的确是一个漂亮的设计，我是怎么知道的呢？

**格言14︰任何的工具以我们所知道的方法来使用都会有用，但一个真正了不起的工具会以你从未想过的使用方法来发挥它的功能。**

支持「集体邮箱」的 fetchmail 有一种意料之外的使用方法，就是在以 SLIP/PPP 连线方式连上 ISP 的客户端执行「邮递讨论名单」（mailing list），因为它可以配合客户端的多用户共用 ISP 上同一信箱（用别名 ―― alias ―― 的方法），让每个用户都能在名单上，这表示我们可以在个人的电脑上，透过一个 ISP 的帐号，来维护一个邮递讨论名单，而不必持续连著 ISP。

另一个来自我 beta 测试版的用户的重要需求是接受 8 位 MIME 邮件格式，这很容易做到，因为我过去一直都小心地保持每一个ascii码都是完整的 8 位，并非我未卜先知，而是我遵从另一条法则︰

**格言15︰写作任何的网关类软件时，要尽可能地不去扰动到通讯的数据流 ―― 并且绝对不要丢掉其中任何的数据，除非接收方强迫你这么做。**

如果我当初没有遵从这项原则，那么 8 位 MIME 的支持势必难以加入并容易出错，所以我需要做的只是研读 RFC 1652[^15]，然后加入显然得知的代码以产生 MIME 的标头。

一些欧洲的用户要我在程序中加入选项，用来限制每次连线取回邮件的数目（这样他们才能控制昂贵的电话线路连线花费），我拒绝了许久，甚至到现在，我对这个选项的加入仍感到不太愉快，但假如你是在为全世界写程序，那么你就应该听取你客户们的意见 ―― 这个原则不会改变，因为他们会以金钱之外的形式给你报酬。

## 第九章 由 Fetchmail 学到的一些经验

在我们回头讨论一般软件工程的议题前，由 fetchmail 得来的一些特殊教训值得深思。

Fetchmail 配置文件（rc file）的语法包括可有可无的关键字，这些如「噪音」般的字眼会被语法分析程序忽略，这些字的加入，使得配置文件的语法和英文很接近，和传统中简洁的「关键字 ―― 设定值」配对表示法（把噪音字去掉就可以得到）比较起来，要来得容易阅读。

这个教训开始于某一个夜晚的实验，我注意到配置文件中的宣告语法可以组成一个迷你的祈使语言。（这也是为什么我把原来 popclient 中的关键字 server 改成 poll）。

对我而言，如果把这个祈使语言弄得更像英文，那会让 fetchmail 更易于使用，虽然我现在信服如 Emacs、HTML 及许多数据库引擎制定出来的模范语言，在正常情况下我也不那么迷恋英文的语法。

传统的程序员喜欢非常精确而简洁的配置语法，不希望有任何冗余在其中，这是因为早期的电脑计算资源昂贵而遗留下来的观念，他们认为语法分析的过程要节约计算资源，并要尽可能的简单。英文的语句大约有百分之五十的冗余，所以不利于做为配置语法。

但这并非我在正常的情况下不用英文语法的原因，我在此提及是为了推翻像英文的语法不适合作配置语法的论点，当中央处理器和内存都变得便宜时，配置语法的简洁已不再是我们的目标，现在的情况是︰一个电脑语言中符合人性易于使用的重要性已超过节约电脑的计算资源。

然而还是有好几个地方要小心，其中之一是语法分析过程变得比较复杂的代价 ―― 你不会想把这个特点（使用像英文的配置语法）变成程序错误的来源及用户的疑惑处。另一个是当我们要订出一个像英文的语言时，通常需要做些修改，表面上看起来修改过后的语法可重组出自然语言，但可能也会因修改过以致于和传统的配置语法一样，令人感到疑惑。（我们可以在许多所谓的第四代程序语言和商业用的数据库查询语言看到这个现象）

Fetchmail 的控制语法看起来避免了这个问题，因为我严格地限制控制语法的范围，它不是一个以通用为目的的语言，它简单并不很复杂，所以在极小的英文子集和真正的控制语言之间的相混处很少，我认为这里还有一个更广义的教训︰

**格言16︰当你设计的语言没有一处是 Turing-complete，你可以采用比较平易的语法。**

另有一个教训是关于含糊的保密性，有一些 fetchmail 的用户要我修改程序，以把经保密处理的凭证储存于配置文件内，这样一来，偷窥者就没办法看到真正的密码了。

我并没有这么做，因为这个做法并不能达到真正的安全，能拿到读取你配置文件权限的人，也能以你的身份执行 fetchmail ―― 如果你的密码经保密处理存在配置文件中，他们可以由 fetchmail 中取得解码程序来得到你真正的密码。

如果我把程序改成可以在 fetchmail 的配置文件中储存保密的密码，那会给认为这并不难的人们对保密性的错误观念。一般的守则应该是:

**格言17︰一个保密系统是否安全依存于它隐藏的秘密，注意不要有「虚拟秘密」。**[^16]

## 第十章 市集模式必要的条件

早先看过这篇文章的书评家和试读者都提出同样的问题，那就是以市集模式开发软件，获得成功的先决条件为何？包括项目领导人的资格，代码到什么样的程度，才对社群发布并开始成立协同开发团队。

相当明显的，任何人无法以市集模式建立软件基础[^17]，但是可以用市集模式来测试，debug，改进软件，在一个项目的起始点很难运用市集模式，Linus 没试过，我也没有。项目初始的协同开发团队需要有一些东西可以测试，可以执行。

当你开始召募项目团队时，你必须能提出大致合理的保证，你的程序不需要运作得很好，它可以暴力，有错，不完整，及注释贫乏，只要它可以使潜在的协同开发者相信，这个程序在可预见的未来大有可为。

Linux 和 fetchmail 公开发布时都具有强健及吸引人的设计，许多人认为这和我所报告的市集模式有所不同，并以为这样的设计很重要，甚至进一步做出一个他们的结论 ―― 高度的设计直觉和聪明是一个项目领导人不可或缺的特质。

但是 Linus 的设计由 UNIX 而来，我的设计由原先的 popclient 而来（虽然它后来改变甚大，比例上说来还超过 Linux），所以市集模式项目的领导人或协调者真的需要格外的设计技巧？或者能提升别人的设计技巧呢？

我想对于项目协调者是否能做出耀眼的设计并不重要，最重要的是协调者是否能认知别人在设计上的好点子。

Linux 和 fetchmail 都证明了这件事，Linus 这位仁兄如同之前所讨论的，他并不是伟大的创新设计师，但他展现了另一种卓越的技巧，即认同别人好的设计点子，且将这些好的设计整合到 Linux 的核心中。而我之前描述过 fetchmail 最有力的设计（藉 SMTP 转发邮件）也来自他人。

这篇文章的早期读者指出︰我低估了市集模式项目中创造力的重要性，因为我自己本身就已具备了许多的创意，所以将此视为理所当然。这真是抬举我，也许这说法有几分真实，相对于写程序及debug，设计应该是我最强的本领。

但以聪明和创意来设计软件的问题在于「习惯的养成」 ―― 当你应该保持程序的强健和简洁时，反而把它弄得花哨而复杂，我曾因犯了这个错以致于把项目搞砸了，但我在 fetchmail 这个项目中小心地控制，避免发生这种错误。

所以我相信 fetchmail 项目的成功部分的原因是我防止设计上「聪明」的倾向，这个论点（至少）已经反驳了设计上的创意是市集模式项目成功的基本条件。以 Linux 来说，假设 Linus Torvalds 在开发程序的过程中，试图在操作系统的基本设计上力求创新，那么我们现在已有的 Linux 内核程序会如此稳定和成功吗？

当然，任何想开始一个市集模式项目的人，应该具备基本程度的设计能力和写程序技巧，但我认为如果他们有认真想过，那他们的程度应该已在要求之上。开源社群对于名誉的重视，给予其中的人们一种微妙的压力，如果无法胜任项目后续的开发，那么就不会想去开始，直到目前，这种惯例似乎仍运作得很好。

还有一种技巧，通常与我们不会把它和软件开发联想在一起，但我认为这和市集模式项目中聪明的设计一样重要，也许还更重要，就是市集模式项目中的协调者或领导人必须有人缘和好的沟通技巧。

这应该很明显，为了召集开发社群，你需要吸引人们，让他们对你所做的有兴趣，并且保持他们加入后工作愉快。技术上的末节很难达成这样的目标，更难以完成整个项目，你个人的人格特质也和项目息息相关。

Linus 是一位好人，令人喜欢并乐于帮助他，这不是巧合，我精力旺盛，活泼外向，喜爱为群众们工作，并具有喜剧演员的本能，这也不是巧合，为了让市集模式项目顺利运作，如果能用一点小技巧来吸引人们，那帮助会很大。

## 第十一章 开源软件的社会关联性

我们谈过︰最好的程序起自于作者个人要解决他每天的切身之痛，然后因为这通常也是许多人的痛处，所以这个程序便开始传播，这让我们把**格言1**用另一种更有用的说法来陈述︰

**格言18︰要解有趣的问题，从寻找你感兴趣的问题开始！**

所以 Carl Harris 写了早期的 popclient，而我写了 fetchmail，然而这句格言应早已为人所知许久，Linux 和 fetchmail 开发的历史似乎要让我们注意到这有趣的一点，就是软件开发的下一步 ―― 用户和协同开发者组成了庞大而活跃的社群，带动软件的演化。

在《人月神话》一书中，Fred Brooks 观察到︰程序员的时间有不可替换性，在一个进度已经落后的项目中，加入更多的开发者只会使进度更加落后，他讨论到一个项目的复杂度和人员间沟通的代价以参与开发人数的平方倍成长，而完成的进度只随人数做线性成长，这个声明自从发布以后，就被称为 Brooks 定律且被视为真理，但假如 Brooks 定律主宰了一切，那么根本就不可能有 Linux 这个操作系统。

Gerald Weinberg 的经典著作《计算机程序写作之心理学》（The Psychology of Computer Programming）中有后见之明，提出对 Brooks 定律极为重要的修正，在 Weinberg 对「忘我编程」（egoless programming）的讨论中，他观察到在软件工作室中，如果程序员们不只「自扫门前雪」，而是鼓励其他的程序员去看他们的程序，以找出错误或提出改进的建议，那么程序改善的速度会远超过每个程序员只顾自己的情况。

也许 Weinberg 的术语选择不当，以致于原本该为人所接受的观念却未被接受，当想到用「忘我」（egoless）来形容因特网上的电脑黑客，令人发出微笑，但我认为他的论点在今天要比过去更有力。

集市模式通过充分利用「忘我编程」效应，有力地减轻了 Brooks 定律的影响。Brooks 定律背后的原理并没有被废除，但考虑到庞大的开发者群体和廉价的通信，它的影响会被在其他方面并不明显但更有力的的非线性效应所淹没。这类似于牛顿经典物理学和爱因斯坦相对论之间的关系--旧系统在低速宏观世界中仍然有效，但如果你把质量和速度推得足够高，你就会得到惊喜，比如核爆炸或Linux。

UNIX 的历史其实早已准备好我们从 Linux 学到的东西（以及经由我实验得证的事情，这个实验经过仔细地仿效 Linus 的方法[^18]，但规模较小），当大家还认为写程序仍然是单打独斗的行为时，真正了不起的黑客已经在善用社群的注意力和脑力。在一个封闭项目中的程序开发者，他们只单靠自己的头脑，所达成的进度将落后于知道怎么搞一个开源项目的开发者，因为在开源的项目中，有数以百计的人在报告错误及改进程序。

但是传统 UNIX 的世界因为好几个原因，无法把这个方法的功效发挥到最大，其中包括︰不同版权的法律限制，商业机密，市场上的利益等等，还有一个原因（算是后见之明）就是︰当初的因特网还不够发达。

在廉价的因特网来临之前，有一些地域性的社群集中在一起，他们的文化鼓吹著 Weinberg 的「忘我」的程序写作，其中的程序开发者可以轻易地吸引许多有技巧的建言者和协同开发者，如贝尔实验室，麻省理工学院人工智能实验室及加州大学伯克利分校 ―― 这些地方都是创新的来源，都带有传奇色彩，至今都仍具有影响力。

Linux 是第一个致力于把全世界当成是它智库的项目，我并不认为在 Linux 的孕育期恰好诞生了全球资讯网是个巧合，而且在 Linux 开发的早期，因特网服务供应商的事业正在起飞，因特网的主流商机正在爆发，Linus 是第一位学会在因特网普及的情况下利用新游戏规则的人。

虽然廉价的因特网是 Linux 模式演进的必要条件，但我认为它并非充分条件，另一个极重要的因素是项目中领导人的领导风格，以及一群合作的客户，其中有人会被开发者吸引而成为协同开发者，进而把网络媒体的功能发挥到最大。

但我们要问什么是领导风格？客户是哪些人？他们之间的关系并非依赖权力而建立 ―― 或者就算是，强制的领导风格没办法带给我们今天这样的成果，Weinberg 引用十九世纪俄国无政府主义者 Pyotr Alexeyvich Kropotkin 自传中＜纪念一位革命家＞（Memoirs of a Revolutionist）的一段，来解释这个问题︰

> 因自幼在拥有佃农的地主家庭中长大，当我的生命开始活跃时，就像那时所有的年轻人一样，我们非常相信命令，指使，责骂以及处罚等等行为的必要性，但当我早期必须管理正式的企业时，我要和自由的人打交道，任何错误可能最后都会引发严重的后果，我才开始接受命令和规定与建立共识的不同之处，前者在军事体系中效用极佳，但在真实的生活中却一文不名，真实生活中的目标，是在许多人同心协力下达成的。

「许多人同心协力」（severe effort of many converging wills）正是像 Linux 这样的项目所需要的 ―― 「命令法则」（principle of command）并不适用于被我们称为因特网的无政府主义者志愿者，为了更有效的运作和竞争，想要领导与他人合作的项目的电脑黑客，必须学习如何吸引和激励有兴趣的社群，并且是在 Kropotkin 所建议的「共识法则」（principle of understanding）的模式下进行，他们也必须要学习去使用「Linus法则」[^19]。

稍早我提及「Delphi效应」是因为它可能可以解释「Linus法则」，但在生物学和经济学中的自适应系统中，有更多类似的地方可以更有力地印证它，Linux 的世界从许多方面看来，像是一个自由的市场或生态，由一群个体所组成，这些个体以一种自发性的自我更正程序，试着去发挥他最大的功用，所发挥出来的功用比起集中式的规划要来得更精巧，更有效率，这种方式正是在寻求「共识法则」（principle of understanding）。

Linux 黑客们最大化的实际利益不是典型的经济价值，而是在黑客中得来无形的自我满足和荣誉，（你也许可以认为他们的动机是「利他」，但这忽略了一项事实，就是利他主义只是利他主义者自我满足的一种形式），以这种方式进行的志愿者文化并非真的不寻常，就我长期参加的一个科幻小说俱乐部来说，它不像电脑黑客俱乐部那么明显地以「egoboo」（ego-boosting 或在同好圈里增强某人的信誉）做为驱动志愿者的力量。

Linus 在 Linux 项目中，成功地坐上项目守门员的位置（这个项目大部份的工作都由其他人所完成），也成功地培养项目的利基，直到它可以自我维持，这显示 Linus 精确地抓住 Kropotkin 所说「建立共识」的精神，用这个像经济学的观点来看 Linux 的世界，让我们知道共识是如何作用的。

我们可以把 Linus 的方法，视作一条开创有效率市场的路 ―― 以最强韧的方式联合个别的黑客来达成困难的目标，这些目标只有在持续的合作下才能达成。在 fetchmail 的项目中（虽然规模比较小），我已经展示出 Linus 的方法可以用在别的项目，并同样有好的成果，或许我有意地，更有系统地利用他的方法。

许多人（尤其是在政治上不信任自由市场的）以为重视自我的个体文化会造成分裂，自扫门前雪，浪费，私密，和敌对，只要举一个简短的实例，就可以很明显地证明这个看法是错的，这个例子就是 Linux 相关的说明文档的多样，品质，和深度都相当令人惊讶，程序员不喜欢写说明文档似乎是金科玉律，但 Linux 的黑客们是如何写出这么多的文件呢？很明显地，Linux 重荣誉的自由市场运作得要比商业软件生产者重金投资的说明文档撰写公司好。

Fetchmail 和 Linux 这两个项目都展示出藉由适当地回报许多黑客，优秀的开发者或协调者能利用因特网，获得许多协同开发者，但不致让项目因混乱而失败，所以针对 Brooks 定律，我提出以下的反驳︰

**格言19︰假如项目开发协调者拥有至少跟因特网一样好的媒体，而他也不靠强制力来领导，那么一群人必定胜过一个人。**

我认为开源软件的将来属于知道如何进行 Linus 游戏规则的人，属于离开教堂拥抱市集的人，这并不是说个人的眼光和智慧不再重要，而是我认为开源的软件的优势将属于一种人，他以个人的眼光和智慧开始一个项目，并且之后能有效地号召有兴趣的志愿者群来加入他的项目。

也许不只是开源的将来，非封闭性源代码的开发者也能吸引 Linux 社群的智库到他们的问题上，很少有人付得起 fetchmail 项目中超过两百位的贡献者的雇佣费用。

也许最后开源文化会赢，但不是因为合作是善的，或软件「栅栏」（hoarding）是恶的（假设你相信后者，但 Linus 和我则否），而是因为封闭源代码的世界无法在演化的角力中胜过开源的社群，社群能投入的资源要比封闭源代码的项目来得多。

## 第十二章 管理与马其顿防线

1997年版的《教堂与市集》这篇文章的结论是 ―― 网络上由程序员（或者该说是无政府主义者）形成的快乐游牧民族，正以锐不可挡的气势冲击著传统封闭软件的阶层式世界。

仍有许多怀疑论者不能信服，但他们提出来的问题应该受到公平的审视，对市集论点最主要的反对意见可归结为︰市集的支持者低估了传统管理的生产力乘积效应（productivity-multiplying effect）。

传统的软件开发经理人反对的论点在于开源项目的偶然性（casualness），项目团队在偶然中成立，改组，和解散，虽然开源社群比起任何封闭开发者拥有人数上明显的优势，但偶然性却否定了这个优势。他们目睹软件开发需在时间上持续付出代价，并且要看客户是否继续投资重量级的产品，而不是有多少人把骨头丢到锅里等待它熬成汤。

这个论点有一些意义，但事实上我已在《神奇熔炉》（*The Magic Cauldron*）这篇文章中指出，未来软件产业经济的关键在于服务价值。

这个论点也隐藏着一个大问题，就是它假设开源项目无法长久维持，事实上，确实有长久持续开发的开源项目，一直保持一致的开发方向和有效的维护者社群，但其中却没有传统项目管理上的激励组织或制度化控制。GNU Emacs 编辑器的开发正是一个极端且具有代表性的例子，它在十五年间，以统一的结构观点，吸收了数百位贡献者的努力，尽管参与的人这么多，其实只有一个人（原作者）在十五年间持续活跃著。没有一个封闭源代码的编辑器曾创下如此长寿的纪录。

在此，我们有理由质疑传统管理下的项目开发，但这却与其他教堂与市集的论战无关。如果 GNU 的 Emacs 编辑器可以在十五年间，保持一贯的结构，在过去八年间，虽然硬件平台的技术进步飞快，Linux 操作系统也同样做到了，假如（事实如此）有这么多结构良好的开源项目持续的时间超过五年，那么我们不禁要问，传统的项目管理除了带来巨大的额外花费，是否还有其他益处？

传统管理下的软件项目当然不保证在期限内有效执行，不保证不超支预算，不保证实现所有的规格，很难得有一个「管理下」的项目能达到以上任一个要求，更不用说三个都达到了。管理下的项目似乎在它的生命周期中，很难去适应技术上和经济环境上的变化，而开源社群却已证明了开源项目有更高的绩效。（我们可以做一个基本的验证，例如比较因特网三十年的历史和短命的私有网络技术，或者微软windows系统由 16 位转移到 32 位付出的代价和同时期 Linux 轻易地移植到 Intel 系列之外超过一打的平台，其中包含 64 位的 Alpha。）

许多人认为传统商业软件模式下，某些人能提供法律上的保证，如果该软件的方向错了，还可以补救回来，但这是个错觉，大多数的软件合约只宣告商业上的保证，而不是「履行」的保证，而且很少见到有未完成软件成功地补救回来。即使这种情形稀松平常，因为有人可以告而让我们感到宽慰并不是有意义的事。我们不要诉讼，我们要可用的软件。

到底传统项目管理的额外花费带来了什么？

为了了解这个问题，我们首先必须弄清楚软件项目管理者做些什么事，一位我认识的女士在这个工作上表现优异，她说软件项目管理有五个主要功能︰

1. 定义目标，确保每一位成员方向一致。
2. 监督并且确定重要的细节没有被忽视。
3. 诱导成员去做乏味但必要的苦工。
4. 调整成员组织以期发挥最大生产力。
5. 安排足够的资源以支持整个项目。

这些很明显地都是很有价值的目标，但在开源模式，及开源的社会意义下，这些目标看起来似乎很突兀，我们以倒过来的顺序看︰

我的朋友提到争取资源基本上是防御行为，一旦你有了人，有了机器和办公室空间，你就必须保卫他们，以防被其他项目经理抢走，或者被高层榨干。

但开源的开发人都是志愿者，在所从事的项目中，依个人的兴趣和能力，自行分工（就算他们是在有给职下精研开源软件，一般而言，上述仍然属实。）志愿者的风格自动倾向于争取资源的攻方，他们带来自己所拥有的资源，因此对开源项目的管理者来说，很少需要打传统的「保卫战」，或者根本就不必要。

不论如何，在廉价的个人电脑和快速网络网络的世界中，我们发现了一个非常一致的事实︰唯一有限的资源，就是具熟练技术的参与者。当一个开源项目成立后，原则上不需要争取电脑，网络或者办公室空间，只有当开发者们失去兴趣时，它才会结束。

以此为例，非常重要的一点︰开源的黑客们如何自行分工以发挥最大的生产力 ―― 这个环境会冷酷地挑选出称职者。我的朋友同时熟悉于开源世界和大型封闭性项目，她相信开源已算是局部成功了，因为它的文化只接受最具才能的5%或说是写程序的人。她大部份的时间花在组织运用其余95%的人，并且亲身见识到（许多人都知道）最强的程序员的生产力和仅能胜任的程序员相差100倍。

这个差异的倍数一定会引来一个笨问题︰如果个别的项目，甚至整个领域，把能力差的人减到少于 50%，不就好了吗？熟虑的管理者早已知道︰如果传统软件项目管理的功能只在于把能力不及格的人训练到及格，那么软件项目管理就不值得去做了。

开源社群的成功，更加突显出这个问题，证明由因特网上征召自行分工的志愿者，通常省钱又有效，胜过管理整栋在做其他事的人。

以上把我们带向「动机」的问题，与我朋友观点同义的，且常听到说法是︰传统软件项目的管理，是对于缺乏主动性的程序员的一种补救措施。

这个答案通常伴随一点声明︰我们对开源社群能完成工作的信赖，源自于「性感」的吸引力或者技术上的喜悦，缺乏这两个要素的工作，如果不是没人做，就是做得很糟，除非有经理挥动鞭子，驱使不自由的受雇者去搅局，我在＜[*Homesteading the Noosphere*](http://www.tuxedo.org/~esr/magic-cauldron/)＞这篇文章中已经由心理和社会的因素去质疑这个论点。然而就现在的目的而言，我想︰点出接受这种说法背后的意义会更为有趣。

如果传统，封闭，重管理的软件开发风格所防御的是无趣的问题，那么在该应用领域中，以马其顿防线为手段，只有在无人发现这些问题的趣味，或者无人绕过这些问题的情况下，才算有效。但在目前，软件无趣的部份有了开源的竞争者，用户将知道最后有人处理的原因是︰因为问题本身的魅力，吸引了解决问题的人 ―― 不只在软件界，或者其他创造性的工作中，问题的魅力是一个比只提供金钱还更有效的推动因素。

如果运用传统的管理结构只是为了激励被管理者的动机，那么这也许是一个好的战术，但却是个坏的战略，短期内会赢，但在长期会输。

到目前为止，传统软件项目管理看起来有两点（安排资源，调整组织）比不上开源，似乎在第三点（动机）上苟延残喘，而被围攻的可怜经理，在监督的工作上得不到任何援助；而开源社群最强的一点就在于分散式的审校，这点胜过确认有无细节被遗漏的任何传统方法。

我们可不可以略去讨论定义目标是不是传统项目管理的额外付出呢？也许吧，但如果要这么做，我们需要一个好理由让我们相信︰管理委员会和运作计划在定义有价值和广义的目标时，要比开源世界的项目领导人和资深参与者更成功。

表面上看起来很困难，但并不是因为作对的开源社群（Emacs 的长寿，Linus Torvalds 谈论「称霸世界」以激励开发者的能力）造成的，因为定义软件项目的目标，是传统机制下的宣示性庄严。

软件工程中最为人所知的一个理论是︰有60%到75%的传统软件项目如果不是未完成就是被用户所拒用。假如这个数字范围和真实状况很接近（我尚未遇过有经验的经理人在争论这个数字），那么就有更多的项目没有遵循目标开发，而目标如果不是（a）不切实际就是（b）错了。

这点更甚于其他问题，在今天的软件工程世界，「管理委员会」（management commitee）这个惯用语令听的人脊背发凉 ―― 即使（或者特别地）听者本身就是管理者，只有程序员会如此的日子早已过去了；管理者桌上现在都放有「呆伯特」（Dilbert）漫画[^20]。

因此，我们对传统项目管理者的回应很简单︰如果开源社群真的低估传统管理的价值，那为什么你们当中有这么多人鄙视你们自己管理的作为呢？

既存的开源社群又再次突显出这个问题 ―― 因为乐趣在我们所做的工作中，我们有创意地游戏着，已经以惊人的速度带来技术上，市场占有，和心灵分享上的成功，我们正在证明我们不只能写出更好的软件，而其中的乐趣也是一项资产。

在这一篇文章第一版发布后的两年半，我所能提供的最基本想法，已不再限于开源的视界，但毕竟对许多在过去这些日子身陷诉讼而清醒的人而言，这些想法似乎都是合理的。

甚至，我想提出一个对于软件更深广的认识（也许对每一种造创或专业的工作都适用）在最适挑战 ―― 不会太容易而令人厌烦，不会太困难而难以达成的工作中，人们会获得乐趣，一个快乐的程序员的条件是︰工作量不会太轻，也未被定义不良的目标和压力下的摩擦过度压榨。享受乐趣确保了效率。

相对于在你的工作过程中，如果有恐惧和强烈的厌恶（即使如呆伯特漫画中表达出的变换或讽刺方式），那就表示这个工作过程是失败的。乐趣、幽默、和游戏性是真的资产，这也是我前面为什么写出「快乐的游牧民族」这个名词，而 Linux 的吉祥物是隻人见人爱的企鹅也不仅是个笑话。

将来的事实会证明开源最大的成功之一就是它告诉了我们︰如玩游戏般地工作是从事创造性工作最经济、最有效率的模式。

## 第十三章 结语︰网景公司拥抱市集

当你真的在影响历史时，那种感觉真的很不一样…

1998 年 1 月 22 日，大约是我第一次发布这篇文章之后七个月，网景公司公开声明他们计划要发布通讯家族（Netscape Communicator）的[原始代码](http://www.netscape.com/newsref/pr/newsrelease558.html)，之前我对这件事情的发生一点头绪也没有。

网景的执行副总裁兼首席技术官 Eric Hahn 寄给我一封电子邮件，内容简要如下︰「我代表网景公司的每一个人，向你致谢，因为你帮我们成为第一家做到开源的公司，你的思想和著作是我们做出这个决定的原因。」

接下来一个星期，我接受网景公司的邀请，搭飞机到硅谷参加他们长达一天的策略会议，参与会议的有该公司顶级执行者和技术人员，我们一起设计出网景公司开源的策略及版权，也做了些计划，希望能对开源社区有长远而正面的影响，就如同我之前所说，这件事来得太快，以致于我们定出的策略和版权还不太明确，但在几周内，细节应该可以交代清楚。

网景公司愿意提供一个真实大型的试验，在商业世界中测试市集模式，因此开源的世界正面临著一个危机，假如网景的行动不成功，那么开源的观念在商业界也许就会被鄙弃，在十年内大概不会有公司再碰它。

另一方面，这也是一个空前的机会，华尔街和其他地方对这件事的初始反应是谨慎地正面评价，我们拥有这个机会来证明开源是有益的，假如网景借此行动而重新获得实际的市场，那么它将引发软件工业中一场迟来已久的革命。

明年（1999）将会是非常有意义而且有趣的一年。

并且事实确实如此。当我在2000年中期写下这篇文章时，后来被命名为Mozilla(Firefox)的发展只是一个合格的成功。它实现了网景最初的目标，即拒绝微软对浏览器市场的垄断锁定。它也取得了一些戏剧性的成功（特别是发布了下一代Gecko渲染引擎）。

然而，它还没有像Mozilla创始人最初所希望的那样，从Netscape之外获得大量的开发工作。这里的问题似乎是在很长一段时间里Mozilla发行版实际上打破了集市模式的一个基本规则; 它没有提供一些潜在的贡献者可以很容易地运行和看到工作的东西. (直到发布一年多以后, 从源码中构建Mozilla需要一个专有的Motif库的许可证).

最消极的是(从外界的角度来看)Mozilla集团在项目启动后两年半的时间里没有推出产品级的浏览器，1999年，该项目的一位负责人辞职，抱怨管理不善和错失机会，引起了一点轰动。他正确地指出，"开源"不是万能药。

而事实上并不是这样。Mozilla 的长期前景现在(2000年11月)看起来比Jamie Zawinski写辞职信的时候要好得多--在过去的几周里，每晚发布的版本终于通过了生产可用性的关键门槛。但是Jamie正确地指出，开放源码并不一定能拯救一个现有的项目，因为这个项目存在着目标不明确、代码冗长或软件工程的其他痼疾。Mozilla已经成功地提供了一个例子，同时说明开源如何成功，如何失败。

然而，与此同时，开源理念已经取得了成功，并在其他地方找到了支持者。自Netscape开源以来，我们已经看到了对开源开发模式的巨大兴趣，这种趋势是由Linux操作系统所推动并持续。Mozilla所引发的趋势正在加速继续。

[^1]: GNU 是自由软件基金会（Free Software Fundation）的一个项目，目标是开发出 UNIX 上所有程序的自由版本，Emacs 是自由软件基会开发出来的一支程序，可做文字编辑器，提供写程序的整合开发环境，用来读电子邮件，新闻群组，甚至浏览网页。更详细的资讯请参考 http://www.gnu.org。 ―― 译注。
[^2]: Linus Torvald 是 Linux 内核程序（kernel）的原始作者。 ―― 译注。
[^3]: 在《*Programing Pearls*》，著名的资讯工程格言家 Jon Bentley 评论 Brooks 的观察说「如果你丢弃一次，你将丢弃第二次」。他几乎是对的。他们两人的重点不是你应该预期第一次的尝试是错的，而是以正确的想法开始会比挽救一场灾难来得更有效率。
[^4]: 成功采用市集模式的开源例子，早在因特网时代之前，与 UNIX 无关，这因特网的传统早就存在。[info-Zip](http://www.cdrom.com/pub/infozip/) 这个压缩工具的开发在 1990-1992 年，主要是针对 DOS，就是一个例子。另一个子是 RBBS 电子布告栏（也是针对 DOS），于 1983 年开始，开发了一个强壮的社群，直到目前（1999 年中）都还经常发布新版本，尽管网络邮件与文件分享有更巨大的优势。当 info-Zip 社群依赖网络邮件形成的规模，RBBS 的开发者文化实际上在 RBBS 支撑线上社群，使它完全独立于 TCP/IP 的基础设施。
[^5]: Delphi 是希腊古都，以善作预言的 Apollo 神殿而闻名。 ―― 译注。
[^6]: 对训服操作系统的复杂度来说，透明与同裁审查都是很有价值的，毕竟这不是一个新概念。在 1965 年，时间共享的非常早期阶段，Corbató 与 Vyssotsky，Multics 操作系统的共同设计者[写到](http://www.multicians.org/fjcc1.html)，一般预期 Multics 将在完成后发布…这是为了两个原因，第一是它可以经得起有兴趣者的审查与批评，第二是有义务要展出，未来的设计者才可以让内部操作系统尽可能清晰，如此会有利于发现系统问题。
[^7]: John Hasler 提过一个有趣的解释，我将它称为「Hasler定律」︰重复工作花费的时间与团队大小呈现 sub-quadratic 关係 ―― 至少比那些需要被消灭的过度计划与管理上升的慢。  
这声明并没有否定「Brooks法则」。复杂度与除错规模随着人数而呈现平方上升，不过重复工作的时间成本至少上升的比较慢。从以下这个无可怀疑的事实很难开发出令人信服的推论︰「不同开发者写的代码会造成功能限制，防止重复工作比那些形成大量臭虫且缺乏计划与沟通结果好多了。」  
将「Linus法则」与「Hasler定律」合併可以得出三种软件项目的开发模式。在小型项目（最多三个开发者），没有管理比有一个主要开发者好。在中等规模的项目，传统的管理成本相对低，在防止重复工作与除错有正面助益。  
而大型项目中，跟重复工作相比，传统的管理成本上升的比预期的快多了。虽然跟传统管理方式相比，人多容易发现错误，但是这些上升的成本对于管理这些事情却有结构性的无力。因此，在大型项目，正面效果完全被传统管理所抵销。
[^8]: 实验版与稳定版 Linux 可以对冲彼此的风险。这分裂形成另一个问题︰截止日的死亡。当两边都有一个不可变动的功能清单与截止日，品质荡然无存且会形成大混乱。我输钱给哈佛商业评论的 Marco Iansiti 与 Alan MacCormack，因为他们向我展示了证据，就是鬆绑其中一的规定可以让排程可行。  
截止日固定但功能清单可变动，放弃到截止日仍为完成的功能，这是一个可行的办法；稳定版 Linux 核心就是如此，Alan Cox（稳定版的维护者）相当准时的发布新版本，但不保证特定臭虫何时被修正，或是从实验版引进什么新功能。  
另一个办法是设定想要的功能名单，并只在全部完成后发布；这是实验版 Linux 核心的作法。De Marco 与 Lister 指出这样的排程政策（完成后叫醒我）不只品质最好，而且平均来说，跟务实与激进的排程相比，发布的时间间隔也较短。  
我怀疑在这论文的早期（2000 年初），我严重低估「完成后叫醒我」对社群的生产力与品质的影响。1999 年发布的 GNOME 1.0 带来的经验是，对未成熟产品的压力会抵销一般开放源代码产品应有的品质。  
透明的过程、完成后叫醒我与开发者自我选择，这三者是对开放源代码的品质一样重要。
[^9]: 这不完全精确，因特网为基础的开源项目的混合式组织特征，依 Brooks 的建议，要解决这样的 N^2 复杂度问题，应该採取「外科手术小组」的团队 ―― 但是现实中差异很大。像跟在领导者身边的代码图书馆员这样的专门角色，实际上不存在；相对于 Brooks 当时来说，这角色被更而有力的软件工具集所取代。而且，开源文化强烈依赖 UNIX 传统的模组、API 与数据隐藏 ―― 没有任何一个是 Brooks 所讲的处方。
[^10]: 反对者跟我说，对同一bug的多症状来说，描述bug特征的难度呈现指数式（譬如 Gaussian 分布或 Poisson 分布）上升。如果可能掌握到分布的外观，那会是很有用的资料。这与debug困难度是均匀分布的差别很大，也就是说单一开发者也应该模仿市集模式，针对单一的bug定一个时间上限，超过的话就追踪下一个bug。从一而终不见得是美德…
[^11]: 相反的组合指笨拙的数据结构配上聪明的代码。 ―― 译注。
[^12]: 事实上，上述的这段话他是用「流程图」（flowchart）和「表格」（tables）这两个名词，但由于三十年间专业术语/文化的变迁，这些名词的意义几乎是相同的。 ―― 译注。
[^13]: 「小王子」就是 Antoine de Saint-Exupery 的作品。这句格言也曾在《*Modern Operating System*》一书中被 Andrew S. Tanenbaum 引用来说明操作系统微核心的设计哲学。 ―― 译注。
[^14]: RFC 822 是 Standard for the Format of ARPA Internet Text Messages。 ―― 译注。
[^15]: RFC 1652 是 SMTP Service Extension for 8bit-MIME Transport。 ―― 译注。

[^16]: 以 fetchmail 为例，隐藏的秘密是指「通行密码」，「虚拟秘密」是指把通行密码编码后存于配置文件中。 ―― 译注。
[^17]: 一个人能不能采取市集模式从无到有的开发项目，取决于市集模式是否能够支持创造性的工作。有人认为，缺乏强而有力的领导力，市集模式只能在目前最尖端的技术上做複製与小幅度改良，而无法开发出最尖端的技术。这也许是 [Halloween Documents](http://www.opensource.org/halloween/) 最无耻的论述，这令人尴尬的两份微软内部文件如此描述开源现象。作者比较了这个类似 UNIX 系统的 Linux 系统是在「追尾灯」（chasing taillights）（当一个项目达到最先进技术的门槛时），认为管理才能进一步扩大前进。  
如果我们把开源替换为 Linux，会发现这跟新的情境差很远。在过去，开源社区不会借着追尾灯或管理制度发明 Emacs 或 WWW 或因特网 ―― 但目前确有非常多创新是采用开源模式。GNOME 项目就是最先进的 GUI，而且在 Linux 社群外也引起相当的注意。还有其他不胜枚举的例子，有兴趣的人可以去看一下 [Freshmeat](http://freshmeat.net/) 等等的项目。  
认为教堂模式（或市集模式，或其他种类的管理结构）能够让创新更值得信赖有个更根本的错误。这完全是无稽之谈。乌合之众没有突破性的洞察力 ―― 即使市集模式的无政府论者没有真正的原创，这使得目前还能生存的企业人士可以赌注维持现状。*洞察力来自于个人*。大多数围绕在这些人身边的社群机制，都希望对于突破性的洞察力更有回应 ―― 滋养与严苛的测试，而不是压榨它们。  
一些人会说这是不切实际的观点，一个典型过时独创者的回归。并非如此，我不是断言这些已出现的人没有突破性的洞察力做开发，而是我们了解同裁审查对于高品质结果是必要的。当然，这些开发的起源来自于一个人的好点子 ―― 而且这是必要的火花。  
因此，创新的根本问题（不管是软件或是其他方面）是如何不压榨它 ―― 或者是更根本的，如何让这些有洞察力的人群越来越多。
推论教堂模式可以做到而低进入门槛的市集模式做不到，这是可笑的。一个是可以让众人合作的社会环境激励创新；而等级制度下的创新却需要做一些政治性的行销才能为自己的想法开发，不然会有被开除的风险。  
如果我们看一下采用教堂模式的软件开发历史，会很快的发现那相当稀少。大型机构依赖大学的研究中心来开发新的点子（因此 Halloween Documents 的作者对于 Linux 的快速开发成果感到相当感冒），或者买一些拥有创新者成果的小型公司；这两种都不是教堂模式，实际上，很多的创新就是被 Halloween Documents 所讚扬的管理方式扼杀的。  
那是负面的部份，读者应该著重在正面的部份。以实验的精神，我提议以下的方式︰选一个你一直信仰的原创原则，例如「当我看见就能了解」。选一个跟 Linux 竞争的封闭源代码操作系统，与一个公认在这上面运行的最好的源代码。观察该源代码与 Freshmeat 一个月。每天计算在 Freshmeat 上原创的成品，然后对比你选的源代码的原创成品的数字。三十天后，统计两者的数据。  
当我写本文的时候，Freshmeat 发布了 32 个，我选的源代码发布了 3 个，这在 Freshmeat 算慢的，但经验上 3 这个数字对封闭源代码来说是相当快的。
[^18]: 现在我们有一个比 fetchmail 更有指引意义的市集模式项目，[EGCS](http://egcs.cygnus.com/)，实验性的 GNU 组译系统。  
这项目是在 1997 年 8 月中发布的，作为一个早期《教堂与市集》的尝试。因为该项目的发起者觉得 GCC 的开发已经迂腐了。在之后大约二十个月，GCC 与 EGCS 各自平行开发 ―― 两者的开发者都来自一样的母体，都源于一样的 GCC 基础源代码，使用高度雷同的 UNIX 工具集与开发环境。唯一不同的是，EGCS 采用市集模式开发，而GCC 采用类似教堂模式的开发。搭配封闭的开发者团队与发布间隔较长。  
这很接近可控制变因的实验，我们想知道的是哪一个比较戏剧性。在这几个月，EGCS 在功能上大幅度领先，较好的最佳化与对 FORTRAN 跟 C++ 的支持。很多人都认为 EGCS 的开发状况比同时期的 GCC 好，而且主要的 Linux 发行版都换到了 EGCS。  
在 1999 年 4 月，自由软件基金会（GCC 的官方支持机构）解散了 GCC 原来的开发团队，将 EGCS 的团队纳入官方支持。
[^19]: 当然，Kropotkin 的评论与「Linus法则」引起关于社会组织控制学的广泛议题。另一个软件工程的理论则建议「Conway法则」 ―― 「如果你有四组人做组译器，你会得到一个四重（4-pass）组译器」。原始的叙述比较一般化︰「组织会以自己内部的沟通结构设计系统」。更简洁的说，「方式决定结果」或「过程变成产品」。  
值得注意的是，开源社区的组织形式与功能才很多层次相配合。到处都是网状架构，不只是因特网如此，人们在分散、鬆散与同裁的结构工作，其中也会发生延迟与降级。在这样的环境中，每一个节点都需要其他节点自愿性的配合才能互动与合作。  
对于社群令人震惊的生产力来说，同裁合作的部份是必要的。关于 Kropotkin 要处理的权力关系，「SNAFU原则」有进一步的论述︰「平等才可能有真正的沟通，因为对于劣等者来说，讲善意的谎言比陈述事实更有吸引力。」开创性的团队合作依赖于真正的沟通，在权力的展示下反而会被严重拖累。开源社区就是这样的情况，这将在除错、低生产力与机会消耗异常巨大的成本。  
此外，「SNAFU原则」预测在需要授权的组织中，决策者与现实会慢慢脱节，对决策者的资讯太多会变成善意的谎言。这情形在传统的软件开发很容易见到，劣等者有强烈动机隐瞒、忽视与简化问题。当这过程变成产品是，那会是一个大灾难。

[^20]: 指管理者也会害怕自己成为漫画中那个老板。 ―― 译注。

转载在 [The-Cathedral-the-Bazaar-zh](https://github.com/thuwyh/The-Cathedral-the-Bazaar-zh/blob/master/%E5%A4%A7%E6%95%99%E5%A0%82%E4%B8%8E%E9%9B%86%E5%B8%82.md)