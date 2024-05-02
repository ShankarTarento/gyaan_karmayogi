class SocialMedia {
  final String url, imagePath;

  SocialMedia({this.url, this.imagePath});

  static List<SocialMedia> get items => [
        SocialMedia(
            url: "https://www.linkedin.com/company/karmayogi-bharat/",
            imagePath: "assets/img/linkedin.svg"),
        SocialMedia(
            url: "https://x.com/iGOTKarmayogi?t=OUEVuskmXbrTNdPuIBaHuw&s=09",
            imagePath: "assets/img/x_icon.svg"),
        SocialMedia(
            url:
                "https://instagram.com/karmayogibharat?igshid=MzRlODBiNWFlZA==",
            imagePath: "assets/img/instagram.svg"),
        SocialMedia(
            url:
                "https://www.facebook.com/profile.php?id=100089782863897&mibextid=ZbWKwL",
            imagePath: "assets/img/facebook.svg"),
        SocialMedia(
            url: "https://youtube.com/@karmayogibharat?feature=shared",
            imagePath: "assets/img/youtube.svg")
      ];
}
