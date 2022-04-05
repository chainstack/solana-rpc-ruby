require 'json'
require_relative 'request_body'
require_relative 'helper_methods'

module SolanaRpcRuby
  ##
  # WebsocketsMethodsWrapper class serves as a wrapper for solana JSON RPC API websocket methods.
  # All informations about params:
  # @see https://docs.solana.com/developing/clients/jsonrpc-api#subscription-websocket
  class WebsocketsMethodsWrapper
    include RequestBody
    include HelperMethods

    # Determines which cluster will be used to send requests.
    # @return [SolanaRpcRuby::WebsocketClient]
    attr_accessor :websocket_client

    # Cluster where requests will be sent.
    # @return [String]
    attr_accessor :cluster

    # Unique client-generated identifying integer.
    # @return [Integer]
    attr_accessor :id

    # Initialize object with cluster address where requests will be sent.
    #
    # @param api_client [ApiClient]
    # @param cluster [String] cluster where requests will be sent.
    # @param id [Integer] unique client-generated identifying integer.
    # @param client_options [Hash] map of options for websocket_client.
    def initialize(
      websocket_client: WebsocketClient,
      cluster: SolanaRpcRuby.ws_cluster,
      id: rand(1...99_999),
      client_options: {}
    )
      @websocket_client = websocket_client.new(cluster: cluster, options:client_options)
      @id = id
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#accountsubscribe
    # Subscribe to an account to receive notifications when the lamports or data for a given account public key changes
    #
    # @param account_pubkey [String]
    # @param commitment [String]
    # @param encoding [String]
    # @param &block [Proc]
    #
    # @return [Integer] Subscription id (needed to unsubscribe)
    def account_subscribe(account_pubkey, commitment: nil, encoding: '', &block)
      method = create_method_name(__method__)

      params = []
      params_hash = {}
      params_hash['commitment'] = commitment unless blank?(commitment)
      params_hash['encoding'] = encoding unless blank?(encoding)

      params << account_pubkey
      params << params_hash if params_hash.any?

      subscribe(method, method_params: params, &block)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#accountunsubscribe
    # Unsubscribe from account change notifications
    #
    # @param subscription_id [Integer]
    #
    # @return [Bool] unsubscribe success message
    def account_unsubscribe(subscription_id)
      method = create_method_name(__method__)
      unsubscribe(method, subscription_id: subscription_id)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#blocksubscribe---unstable-disabled-by-default
    # This subscription is unstable and only available if the validator was started with the --rpc-pubsub-enable-block-subscription flag. The format of this subscription may change in the future
    #
    # Subscribe to receive notification anytime a new block is Confirmed or Finalized.
    #
    # @param filter [String] # 'all' or public key as base-58 endcoded string
    # @param commitment [String]
    # @param encoding [String]
    # @param transaction_details [String]
    # @param show_rewards [Boolean]
    # @param &block [Proc]
    #
    # @return [Integer] Subscription id (needed to unsubscribe)
    def block_subscribe(
      filter,
      commitment: nil,
      encoding: '',
      transaction_details: '',
      show_rewards: nil,
      &block
    )
      method = create_method_name(__method__)

      params = []
      param_filter = nil
      params_hash = {}

      param_filter = filter == 'all' ? filter : { 'mentionsAccountOrProgram': filter}

      params_hash['commitment'] = commitment unless blank?(commitment)
      params_hash['encoding'] = encoding unless blank?(encoding)
      params_hash['transactionDetails'] = transaction_details unless blank?(transaction_details)
      params_hash['showRewards'] = show_rewards unless blank?(show_rewards)

      params << param_filter
      params << params_hash if params_hash.any?

      subscribe(method, method_params: params, &block)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#blockunsubscribe
    # Unsubscribe from block notifications
    #
    # @param subscription_id [Integer]
    #
    # @return [Bool] unsubscribe success message
    def block_unsubscribe(subscription_id)
      method = create_method_name(__method__)
      unsubscribe(method, subscription_id: subscription_id)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#logssubscribe
    # Subscribe to transaction logging
    #
    # @param filter [String]|[Hash]
    # @option filter [Array] :mentions
    # @param commitment [String]
    # @param &block [Proc]
    #
    # @return [Integer] Subscription id (needed to unsubscribe)
    def logs_subscribe(filter, commitment: nil, &block)
      method = create_method_name(__method__)

      params = []
      params_hash = {}
      params_hash['commitment'] = commitment unless blank?(commitment)

      params << filter
      params << params_hash

      subscribe(method, method_params: params, &block)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#logsunsubscribe
    # Unsubscribe from transaction logging
    #
    # @param subscription_id [Integer]
    #
    # @return [Bool] unsubscribe success message

    def logs_unsubscribe(subscription_id)
      method = create_method_name(__method__)
      unsubscribe(method, subscription_id: subscription_id)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#programsubscribe
    # Subscribe to a program to receive notifications when the lamports or data for a given account owned by the program changes
    #
    # @param account_pubkey [String]
    # @param commitment [String]
    # @param encoding [String]
    # @param filters [Array]
    # @param &block [Proc]
    #
    # @return [Integer] Subscription id (needed to unsubscribe)
    def program_subscribe(
      program_id_pubkey,
      commitment: nil,
      encoding: '',
      filters: [],
      &block
    )
      method = create_method_name(__method__)

      params = []
      params_hash = {}
      params_hash['commitment'] = commitment unless blank?(commitment)
      params_hash['encoding'] = encoding unless blank?(encoding)
      params_hash['filters'] = filters unless blank?(filters)

      params << program_id_pubkey
      params << params_hash if params_hash.any?

      subscribe(method, method_params: params, &block)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#programunsubscribe
    # Unsubscribe from program-owned account change notifications
    #
    # @param subscription_id [Integer]
    #
    # @return [Bool] unsubscribe success message

    def program_unsubscribe(subscription_id)
      method = create_method_name(__method__)
      unsubscribe(method, subscription_id: subscription_id)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#signaturesubscribe
    # Subscribe to a transaction signature to receive notification when the transaction is confirmed
    # On signatureNotification, the subscription is automatically cancelled
    #
    # @param transaction_signature [String]
    # @param commitment [String]
    # @param &block [Proc]
    #
    # @return [Integer] Subscription id (needed to unsubscribe)
    def signature_subscribe(
      transaction_signature,
      commitment: nil,
      &block
    )
      method = create_method_name(__method__)

      params = []
      params_hash = {}
      params_hash['commitment'] = commitment unless blank?(commitment)

      params << transaction_signature
      params << params_hash

      subscribe(method, method_params: params, &block)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#signatureunsubscribe
    # Unsubscribe from signature confirmation notification
    #
    # @param subscription_id [Integer]
    #
    # @return [Bool] unsubscribe success message
    def signature_unsubscribe(subscription_id)
      method = create_method_name(__method__)
      unsubscribe(method, subscription_id: subscription_id)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#slotsubscribe
    # Subscribe to receive notification anytime a slot is processed by the validator
    #
    # @param &block [Proc]
    #
    # @return [Integer] Subscription id (needed to unsubscribe)
    def slot_subscribe(&block)
      method = create_method_name(__method__)

      subscribe(method, &block)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#slotunsubscribe
    # Unsubscribe from slot notifications
    #
    # @param subscription_id [Integer]
    #
    # @return [Bool] unsubscribe success message
    def slot_unsubscribe(subscription_id)
      method = create_method_name(__method__)
      unsubscribe(method, subscription_id: subscription_id)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#slotsupdatessubscribe---unstable
    #
    # This subscription is unstable; the format of this subscription may change in the future and it may not always be supported
    # Subscribe to receive a notification from the validator on a variety of updates on every slot
    #
    # @param &block [Proc]
    #
    # @return [Integer] Subscription id (needed to unsubscribe)
    def slots_updates_subscribe(&block)
      method = create_method_name(__method__)

      subscribe(method, &block)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#slotsupdatesunsubscribe
    # Unsubscribe from slot-update notifications
    #
    # @param subscription_id [Integer]
    #
    # @return [Bool] unsubscribe success message
    def slots_updates_unsubscribe(subscription_id)
      method = create_method_name(__method__)
      unsubscribe(method, subscription_id: subscription_id)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#rootsubscribe
    #
    # Subscribe to receive notification anytime a new root is set by the validator.
    #
    # @param &block [Proc]
    #
    # @return [Integer] Subscription id (needed to unsubscribe)
    def root_subscribe(&block)
      method = create_method_name(__method__)

      subscribe(method, &block)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#rootunsubscribe
    # Unsubscribe from root notifications
    #
    # @param subscription_id [Integer]
    #
    # @return [Bool] unsubscribe success message
    def root_unsubscribe(subscription_id)
      method = create_method_name(__method__)
      unsubscribe(method, subscription_id: subscription_id)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#votesubscribe---unstable-disabled-by-default
    #
    # This subscription is unstable and only available if the validator was started with the --rpc-pubsub-enable-vote-subscription flag.
    # The format of this subscription may change in the future
    #
    # Subscribe to receive notification anytime a new vote is observed in gossip.
    # These votes are pre-consensus therefore there is no guarantee these votes will enter the ledger.
    #
    # @param &block [Proc]
    #
    # @return [Integer] Subscription id (needed to unsubscribe)
    def vote_subscribe(&block)
      method = create_method_name(__method__)

      subscribe(method, &block)
    end

    # @see https://docs.solana.com/developing/clients/jsonrpc-api#rootunsubscribe
    # Unsubscribe from vote notifications
    #
    # @param subscription_id [Integer]
    #
    # @return [Bool] unsubscribe success message
    def vote_unsubscribe(subscription_id)
      method = create_method_name(__method__)
      unsubscribe(method, subscription_id: subscription_id)
    end

    private

    def subscribe(method, method_params: [], &block)
      body = create_json_body(method, method_params: method_params)
      @websocket_client.connect(body, &block)
    end

    def unsubscribe(method, subscription_id:)
      body = create_json_body(method, method_params: [subscription_id])
      @websocket_client.connect(body)
    end
  end
end
