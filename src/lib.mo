import RTW "./rtw";
import Time "mo:base/Time";
import Interface "./icrc45if";
import Int "mo:base/Int";
import Nat64 "mo:base/Nat64";
import Float "mo:base/Float";
import Nat8 "mo:base/Nat8";
import Array "mo:base/Array";
import Nat "mo:base/Nat";

module {

    public type PairId = Interface.PairId;
    public type PairRequest = Interface.PairRequest;
    public type PairResponse = Interface.PairResponse;
    public type ListPairsResponse = Interface.ListPairsResponse;
    public type PairData = Interface.PairData;

    type Mem = {
        rtw : RTW.Mem;
        trade : {
            var last : Interface.Rate;
            var last_timestamp : Nat64;
        };
        var updated_timestamp : Nat64;
        var bids : [(Float, Nat)];
        var asks : [(Float, Nat)];
    };

    public func Mem() : Mem {
        {
            rtw = RTW.Mem(3);
            trade = {
                var last = 0.0;
                var last_timestamp = 0;
            };
            var updated_timestamp = 0;
            var bids = [];
            var asks = [];
        };
    };

    public class PairMarketData({
        mem : Mem;
        id : Interface.PairId;
    }) {

        let rtw = RTW.RTW({ mem = mem.rtw });

        public func registerSwap(left : Nat, right : Nat, rate:Float, usdVolume : Nat) {
            let t = Time.now();
            rtw.updateVolume(0, t, left);
            rtw.updateVolume(1, t, right);
            rtw.updateVolume(2, t, usdVolume);
            let tNat64 = Nat64.fromNat(Int.abs(t));
            mem.trade.last_timestamp := tNat64;

            mem.trade.last := rate;
            mem.updated_timestamp := tNat64;
        };

        public func registerOrderBook(bids : [(Float, Nat)], asks : [(Float, Nat)]) {

            mem.bids := bids;
            mem.asks := asks;
        };

        public func getPairData(depth: ?Interface.DepthRequest) : Interface.PairData {
            let leftVol = rtw.getPairVolume(0);
            let rightVol = rtw.getPairVolume(1);
            let usdVol = rtw.getPairVolume(2);
            let bids = Array.subArray(mem.bids, 0, Nat.min(500, Array.size(mem.bids)));
            let asks = Array.subArray(mem.asks, 0, Nat.min(500, Array.size(mem.asks)));
            {
                id;
                base = {
                    volume24 = leftVol.0;
                    volume_total = leftVol.1;
                };
                quote = {
                    volume24 = rightVol.0;
                    volume_total = rightVol.1;
                };
                volume24_USD = ?usdVol.0; // (optional) Always 6 decimals
                volume_total_USD = ?usdVol.1; // (optional) Always 6 decimals
                last = mem.trade.last; // Last trade rate
                last_timestamp = mem.trade.last_timestamp; // Last trade timestamp in nanoseconds
                bids = bids; // descending ordered by rate
                asks = asks; // ascending ordered by rate
                updated_timestamp = mem.updated_timestamp; // Last updated timestamp in nanoseconds
            };
        };

    };

};
