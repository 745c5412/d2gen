package com.madbot.d2gen.as3

enum class NativeType(val as3Serializer: String) : Type {
    BYTE("Byte"),
    BOOL("Boolean"),
    SHORT("Short"),
    INT("Int"),
    LONG("Long"),
    USHORT("UnsignedShort"),
    UINT("UnsignedInt"),
    ULONG("UnsignedLong"),
    VSHORT("VarShort"),
    VINT("VarInt"),
    VLONG("VarLong"),
    VUSHORT("VarUhShort"),
    VUINT("VarUhInt"),
    VULONG("VarUhLong"),
    FLOAT("Float"),
    DOUBLE("Double"),
    STRING("UTF"),
    VECTOR("Vector");

    companion object {
        private val groupedBySerializer = values().groupBy{it.as3Serializer}

        fun get(as3: String) = groupedBySerializer[as3]
    }
}