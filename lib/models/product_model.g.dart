// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      brand: fields[2] as String?,
      description: fields[3] as String?,
      unit: fields[4] as String,
      category: fields[5] as String,
      mrp: fields[6] as double,
      ourPrice: fields[7] as OurPrice,
      orderFrequency: fields[8] as int,
      createdBy: fields[9] as String?,
      modifiedBy: fields[10] as String?,
      lastOrderedOrderId: fields[11] as String?,
      addedOn: fields[12] as String,
      modifiedOn: fields[13] as String,
      weigh: fields[14] as Weight,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.brand)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.mrp)
      ..writeByte(7)
      ..write(obj.ourPrice)
      ..writeByte(8)
      ..write(obj.orderFrequency)
      ..writeByte(9)
      ..write(obj.createdBy)
      ..writeByte(10)
      ..write(obj.modifiedBy)
      ..writeByte(11)
      ..write(obj.lastOrderedOrderId)
      ..writeByte(12)
      ..write(obj.addedOn)
      ..writeByte(13)
      ..write(obj.modifiedOn)
      ..writeByte(14)
      ..write(obj.weigh);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OurPriceAdapter extends TypeAdapter<OurPrice> {
  @override
  final int typeId = 1;

  @override
  OurPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OurPrice(
      common: fields[0] as double,
      area: (fields[1] as List).cast<AreaPrice>(),
      customerPrices: (fields[2] as List).cast<CustomerPrice>(),
    );
  }

  @override
  void write(BinaryWriter writer, OurPrice obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.common)
      ..writeByte(1)
      ..write(obj.area)
      ..writeByte(2)
      ..write(obj.customerPrices);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OurPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AreaPriceAdapter extends TypeAdapter<AreaPrice> {
  @override
  final int typeId = 2;

  @override
  AreaPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AreaPrice(
      name: fields[0] as String,
      price: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AreaPrice obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AreaPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomerPriceAdapter extends TypeAdapter<CustomerPrice> {
  @override
  final int typeId = 3;

  @override
  CustomerPrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerPrice(
      customerId: fields[0] as String,
      price: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerPrice obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.customerId)
      ..writeByte(1)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerPriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeightAdapter extends TypeAdapter<Weight> {
  @override
  final int typeId = 4;

  @override
  Weight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Weight(
      weight: fields[0] as double,
      unit: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Weight obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weight)
      ..writeByte(1)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
