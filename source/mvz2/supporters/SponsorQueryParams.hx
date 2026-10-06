package mvz2.supporters;

// Ported from: Assets/Scripts/MVZ2/Sponsors/SponsorQueryParams.cs
@:bsonIgnoreExtraElements
class SponsorQueryParams {
    public var page:Int;
    public var per_page:Int;
    public var user_id:String;

    public function new(page:Int, numPerPage:Int = 100, userID:Array<Int> = null) {
        this.page = page;
        this.per_page = numPerPage;
        this.user_id = "";
        if (userID != null) {
            this.user_id = Lambda.map(userID, i -> Std.string(i)).join(",");
        }
    }
}
