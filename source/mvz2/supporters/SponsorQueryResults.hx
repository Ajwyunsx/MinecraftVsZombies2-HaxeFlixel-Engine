package mvz2.supporters;
import unity.networking.UnityWebRequest.Result;

// Ported from: Assets/Scripts/MVZ2/Sponsors/SponsorQueryResults.cs
// PORT-NOTE: MongoDB.Bson attributes are kept as metadata; the Haxe port deserializes with
// json2object/Dynamic instead of the Bson serializer.
@:bsonIgnoreExtraElements
class GenericResp<T> {
    @:bsonElement("ec")
    public var ErrorCode:Int;
    @:bsonElement("em")
    public var Message:String;
    @:bsonElement("data")
    public var Result:T;

    public function new() {}
}

@:bsonIgnoreExtraElements
class ItemList<T> {
    @:bsonElement("total_count")
    public var TotalCount:Int;
    @:bsonElement("total_page")
    public var TotalPage:Int;
    @:bsonElement("list")
    public var List:Array<T>;

    public function new() {}
}

@:bsonIgnoreExtraElements
class SponsorItem {
    @:bsonElement("sponsor_plans")
    public var Plans:Array<Plan>;
    @:bsonElement("current_plan")
    public var CurrentPlan:Plan;
    @:bsonElement("all_sum_amount")
    public var AllSumAmount:String;
    @:bsonElement("first_pay_time")
    public var FirstPayTime:Int;
    @:bsonElement("last_pay_time")
    public var LastPayTime:Int;
    @:bsonElement("user")
    public var User:User;

    public function new() {}
}

@:bsonIgnoreExtraElements
class Plan {
    @:bsonElement("plan_id")
    public var PlanID:String;
    @:bsonElement("rank")
    public var Rank:Int;
    @:bsonElement("user_id")
    public var UserID:String;
    @:bsonElement("status")
    public var Status:Int;
    @:bsonElement("name")
    public var Name:String;
    @:bsonElement("pic")
    public var Picture:String;
    @:bsonElement("desc")
    public var Description:String;
    @:bsonElement("price")
    public var Price:String;
    @:bsonElement("update_time")
    public var UpdateTime:Int;
    @:bsonElement("pay_month")
    public var PayMonth:Int;
    @:bsonElement("show_price")
    public var ShowPrice:String;
    @:bsonElement("independent")
    public var Independent:Int;
    @:bsonElement("permanent")
    public var Permanent:Int;
    @:bsonElement("can_buy_hide")
    public var CanBuyHide:Int;
    @:bsonElement("need_address")
    public var NeedAddress:Int;
    @:bsonElement("product_type")
    public var ProductType:Int;
    @:bsonElement("sale_limit_count")
    public var SaleLimitCount:Int;
    @:bsonElement("need_invite_code")
    public var NeedInviteCode:Bool;
    @:bsonElement("expire_time")
    public var ExpireTime:Int;
    @:bsonElement("rankType")
    public var RankType:Int;

    public function new() {}
}

@:bsonIgnoreExtraElements
class User {
    @:bsonElement("name")
    public var Name:String;

    public function new() {}
}
