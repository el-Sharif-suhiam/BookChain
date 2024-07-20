import Types "types";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import TrieMap "mo:base/TrieMap";

shared (installer) actor class Book(book : Types.Book_metadata, total : Nat) = this {

  type Result<ok, err> = Result.Result<ok, err>;
  stable let creator : Principal = book.owner;
  stable var canisterOwner : Principal = installer.caller;
  stable let book_metadata = book;
  let bookFile = HashMap.HashMap<Nat, Blob>(0, Nat.equal, Hash.hash);
  var nfts : TrieMap.TrieMap<Nat, Types.NFTMetadata> = TrieMap.TrieMap<Nat, Types.NFTMetadata>(Nat.equal, Hash.hash);
  var ownersLedger = HashMap.HashMap<Types.NFT_ID, Types.Account>(0, Nat.equal, Hash.hash);
  stable let bookTotalCap : Nat = total;

  stable let icrc7_tech_queries = {
    allow_transfers = null;
    max_query_batch_size = ?100;
    max_update_batch_size = ?100;
    default_take_value = ?1000;
    max_take_value = ?10000;
    max_memo_size = ?512;
    permitted_drift = null;
    tx_window = null;
    burn_account = null;
  };

  public query func getOwner() : async Principal {
    return creator;
  };

  public shared ({ caller }) func setBookFile(minter : Principal, blobID : Nat, data : [Nat8]) : async Result<(), Text> {
    assert (canisterOwner == caller);
    if (minter == creator) {
      let dataChunk = Blob.fromArray(data);
      bookFile.put(blobID, dataChunk);
      #ok();
    } else {
      return #err("you are not the canister creator");
    };
  };

  public query func getBookSize() : async Nat {
    return bookFile.size();
  };

  func isNFTOwner(nft_id : Nat, caller : Principal) : Bool {
    switch (ownersLedger.get(nft_id)) {
      case (?val) {
        if (val.owner == caller) {
          return true;
        } else {
          return false;
        };
      };
      case (null) {
        return false;
      };
    };
  };

  public query func getBookFile(index : Nat, caller : Principal, nft_id : Types.NFT_ID) : async Result<Blob, Text> {
    if (isNFTOwner(nft_id, caller)) {
      switch (bookFile.get(index)) {
        case null #err("there no data file with this index => " # Nat.toText(index));
        case (?file) #ok(file);
      };
    } else {
      return #err("you don't have any " # book_metadata.symbol # " NFT.");
    };
  };

  public query func getBookMetadata() : async Types.Book_metadata {
    return book_metadata;
  };

  public shared ({ caller }) func nftTransfer(args : Types.TransferArg, from : Principal) : async ?Types.TransferResult {
    assert (canisterOwner == caller);
    switch (ownersLedger.get(args.token_id)) {
      case (?val) {
        if (val.owner == from) {
          ownersLedger.put(args.token_id, args.to);
          switch (nfts.get(args.token_id)) {
            case (?oldVal) {
              let newNfts = {
                oldVal with
                owner = args.to;
              };
              nfts.put(
                args.token_id,
                newNfts,
              );
            };
            case (null) { () };
          };
          return ? #Ok(args.token_id);
        } else {
          return ? #Err(#Unauthorized);
        };
      };
      case (null) {
        return ? #Err(#NonExistingTokenId);
      };
    };
  };

  //icrc7 methods

  public query func icrc7_symbol() : async Text {
    return book_metadata.symbol;
  };

  public query func icrc7_name() : async Text {
    return book_metadata.title;
  };

  public query func icrc7_description() : async ?Text {
    return ?book_metadata.description;
  };

  public query func icrc7_logo() : async ?[Nat8] {
    return ?book_metadata.cover;
  };

  public query func icrc7_max_memo_size() : async ?Nat {
    return icrc7_tech_queries.max_memo_size;
  };

  public query func icrc7_tx_window() : async ?Nat {
    return icrc7_tech_queries.tx_window;
  };

  public query func icrc7_permitted_drift() : async ?Nat {
    return icrc7_tech_queries.permitted_drift;
  };

  public query func icrc7_total_supply() : async Nat {
    return ownersLedger.size();
  };
  //
  public query func icrc7_supply_cap() : async ?Nat {
    return ?bookTotalCap;
  };

  //
  public query func icrc7_max_query_batch_size() : async ?Nat {
    return icrc7_tech_queries.max_query_batch_size;
  };
  //
  public query func icrc7_max_update_batch_size() : async ?Nat {
    return icrc7_tech_queries.max_update_batch_size;
  };
  //
  public query func icrc7_default_take_value() : async ?Nat {
    return icrc7_tech_queries.default_take_value;
  };
  //
  public query func icrc7_max_take_value() : async ?Nat {
    return icrc7_tech_queries.max_take_value;
  };
  //
  public query func icrc7_atomic_batch_transfers() : async ?Bool {
    return ?false;
  };

  //
  public query func icrc7_token_metadata(token_ids : [Nat]) : async [?Types.NFTMetadata] {
    let metadata = Buffer.Buffer<?Types.NFTMetadata>(0);
    for (item in token_ids.vals()) {
      metadata.add(nfts.get(item));
    };
    let array = Buffer.toArray(metadata);
    return array;
  };
  //
  public query func icrc7_owner_of(token_ids : Nat) : async Result<Types.Account, Text> {

    switch (nfts.get(token_ids)) {
      case (?val) {
        return #ok(val.owner);
      };
      case (null) #err("there is no Book copy with this ID.");
    };
  };
  // //
  public query func icrc7_balance_of(accounts : Types.Account) : async Nat {
    var i = 0;
    for (item in ownersLedger.vals()) {
      if (item == accounts) {
        i += 1;
      };
    };
    return i;
  };
  // //
  public query func icrc7_tokens(prev : ?Nat, take : ?Nat) : async [Nat] {
    let start = Option.get(prev, 0);
    let end = Option.get(take, start + 5);
    var i = start + 1;
    var tokensArray = Buffer.Buffer<Nat>(0);
    label loopName while (i <= end) {
      switch (ownersLedger.get(i)) {
        case (?val) { tokensArray.add(i) };
        case (null) { break loopName };
      };
      i += 1;
    };
    return Buffer.toArray(tokensArray);
  };

  // //
  public query func icrc7_tokens_of(account : Types.Account, prev : ?Nat, take : ?Nat) : async [Nat] {
    var ownerTokens = Buffer.Buffer<Nat>(0);
    for ((key, val) in ownersLedger.entries()) {
      if (val.owner == account.owner) {
        ownerTokens.add(key);
      };
    };

    var paginTokens = Buffer.Buffer<Nat>(0);
    let start = Option.get(prev, 0);
    let end = Option.get(take, start + 5);
    var i = start + 1;
    label loopName while (i <= end) {
      switch (ownersLedger.get(i)) {
        case (?val) { paginTokens.add(i) };
        case (null) { break loopName };
      };
      i += 1;
    };
    return Buffer.toArray(paginTokens);
  };

  // //
  public shared (msg) func icrc7_transfer<system>(args : Types.TransferArg) : async ?Types.TransferResult {
    switch (ownersLedger.get(args.token_id)) {
      case (?val) {
        if (val.owner == msg.caller) {
          ownersLedger.put(args.token_id, args.to);
          switch (nfts.get(args.token_id)) {
            case (?oldVal) {
              let newNfts = {
                oldVal with
                owner = args.to;
              };
              nfts.put(
                args.token_id,
                newNfts,
              );
            };
            case (null) { () };
          };
          return ? #Ok(args.token_id);
        } else {
          return ? #Err(#Unauthorized);
        };
      };
      case (null) {
        return ? #Err(#NonExistingTokenId);
      };
    };
  };

  // Function to add a new NFT
  public func mintBookNFT(creator : Types.Account, creationDate : Nat64) : async Result<Nat, Text> {
    if (ownersLedger.size() == bookTotalCap) {
      #err("You can't mint more because the NFT reach the total cap");
    } else {
      let newNFTdata = {
        id = ownersLedger.size() + 1;
        title = book_metadata.title;
        description = book_metadata.description;
        owner = creator;
        creationDate = creationDate;
        author = book_metadata.author;
      };
      ownersLedger.put(newNFTdata.id, creator);
      nfts.put(newNFTdata.id, newNFTdata);
      return #ok(newNFTdata.id);
    };
  };

};
