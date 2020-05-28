class ProductResponeBean {
  int _count;
  Null _next;
  Null _previous;
  List<Results> _results;

  ProductResponeBean(
      {int count, Null next, Null previous, List<Results> results}) {
    this._count = count;
    this._next = next;
    this._previous = previous;
    this._results = results;
  }

  int get count => _count;
  set count(int count) => _count = count;
  Null get next => _next;
  set next(Null next) => _next = next;
  Null get previous => _previous;
  set previous(Null previous) => _previous = previous;
  List<Results> get results => _results;
  set results(List<Results> results) => _results = results;

  ProductResponeBean.fromJson(Map<String, dynamic> json) {
    _count = json['count'];
    _next = json['next'];
    _previous = json['previous'];
    if (json['results'] != null) {
      _results = new List<Results>();
      json['results'].forEach((v) {
        _results.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this._count;
    data['next'] = this._next;
    data['previous'] = this._previous;
    if (this._results != null) {
      data['results'] = this._results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String _name;
  List<Product> _product;

  Results({String name, List<Product> product}) {
    this._name = name;
    this._product = product;
  }

  String get name => _name;
  set name(String name) => _name = name;
  List<Product> get product => _product;
  set product(List<Product> product) => _product = product;

  Results.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
    if (json['product'] != null) {
      _product = new List<Product>();
      json['product'].forEach((v) {
        _product.add(new Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this._name;
    if (this._product != null) {
      data['product'] = this._product.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Product {
  int _id;
  String _category;
  String _name;
  String _price;
  List<ImageUrl> _image;
  List<Tags> _tags;
  String _uploaddate;

  Product(
      {int id,
        String category,
        String name,
        String price,
        List<ImageUrl> image,
        List<Tags> tags,
        String uploaddate}) {
    this._id = id;
    this._category = category;
    this._name = name;
    this._price = price;
    this._image = image;
    this._tags = tags;
    this._uploaddate = uploaddate;
  }

  int get id => _id;
  set id(int id) => _id = id;
  String get category => _category;
  set category(String category) => _category = category;
  String get name => _name;
  set name(String name) => _name = name;
  String get price => _price;
  set price(String price) => _price = price;
  List<ImageUrl> get image => _image;
  set image(List<ImageUrl> image) => _image = image;
  List<Tags> get tags => _tags;
  set tags(List<Tags> tags) => _tags = tags;
  String get uploaddate => _uploaddate;
  set uploaddate(String uploaddate) => _uploaddate = uploaddate;

  Product.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _category = json['category'];
    _name = json['name'];
    _price = json['price'];
    if (json['image'] != null) {
      _image = new List<ImageUrl>();
      json['image'].forEach((v) {
        _image.add(new ImageUrl.fromJson(v));
      });
    }
    if (json['tags'] != null) {
      _tags = new List<Tags>();
      json['tags'].forEach((v) {
        _tags.add(new Tags.fromJson(v));
      });
    }
    _uploaddate = json['uploaddate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['category'] = this._category;
    data['name'] = this._name;
    data['price'] = this._price;
    if (this._image != null) {
      data['image'] = this._image.map((v) => v.toJson()).toList();
    }
    if (this._tags != null) {
      data['tags'] = this._tags.map((v) => v.toJson()).toList();
    }
    data['uploaddate'] = this._uploaddate;
    return data;
  }
}

class ImageUrl {
  String _imageurl;

  ImageUrl({String imageurl}) {
    this._imageurl = imageurl;
  }

  String get imageurl => _imageurl;
  set imageurl(String imageurl) => _imageurl = imageurl;

  ImageUrl.fromJson(Map<String, dynamic> json) {
    _imageurl = json['imageurl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imageurl'] = this._imageurl;
    return data;
  }
}

class Tags {
  String _name;

  Tags({String name}) {
    this._name = name;
  }

  String get name => _name;
  set name(String name) => _name = name;

  Tags.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this._name;
    return data;
  }
}