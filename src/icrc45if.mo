module {
    public type Amount = Nat;

    public type PlatformId = Nat64; 

    public type PlatformPath = Blob; // For the IC that is a Principal
    // Can be anything, a principal, a symbol like BTC, ethereum address, text, etc.

    public type TokenId = {platform: PlatformId; path: PlatformPath}; 

    public type Decimals = Nat8;

    public type DataSource = Principal; // Location from which we can get icrc_38_pair_data. Not necessarily the PairLocation
    
    public type PairId = {base:TokenId; quote:TokenId}; // base token, quote token

    public type Rate = Float; // IEEE 754 floating point numbers 

    public type TokenData = {
        volume24: Amount;
        volume_total: Amount; // Floats can't be used here
    };
 
    public type PairData = {
        id: PairId;
        base: TokenData;
        quote: TokenData;
        volume24_USD : ?Amount; // (optional) Always 6 decimals
        volume_total_USD : ?Amount; // (optional) Always 6 decimals
        last: Rate; // Last trade rate
        last_timestamp: Nat64; // Last trade timestamp in nanoseconds
        bids: [(Rate, Amount)]; // descending ordered by rate
        asks: [(Rate, Amount)]; // ascending ordered by rate
        updated_timestamp: Nat64; // Last updated timestamp in nanoseconds
    };
    
    public type PairInfo = {
        data : DataSource;
        id: PairId;
    };

    public type Level = Nat8;
    // Levels are numbered starting from 1, with 1 being the most aggregated or coarsest level
    // of data, and increasing levels offering finer detail.

    public type ListPairsResponse = [PairInfo];


    public type DepthRequest = {limit:Nat32; level:Level};
    public type PairRequest = {pairs: [PairId]; depth:?DepthRequest}; 

    public type PairResponseOk = [PairData];

    public type PairResponseErr = {
        #NotFound: PairId;
        #InvalidDepthLevel: Level;
        #InvalidDepthLimit: Nat32;
    };

    public type PairResponse = {
        #Ok: PairResponseOk;
        #Err: PairResponseErr;
        };

    // // Can point to different canisters
    // public query func icrc_45_list_pairs() : async ListPairsResponse {
    //     []
    // };

    // // Doesn't have to be in the same canister where icrc_45_list_exchanges is
    // public query func icrc_45_get_pairs(req: PairRequest) : async PairResponse {
    //     [];
    // };

}