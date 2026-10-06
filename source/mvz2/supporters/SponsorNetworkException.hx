package mvz2.supporters;

// Ported from: Assets/Scripts/MVZ2/Sponsors/SponsorNetworkException.cs
class SponsorNetworkException extends haxe.Exception {
    public function new(?message:String = null, ?innerException:haxe.Exception) {
        super(message, innerException);
    }
}
