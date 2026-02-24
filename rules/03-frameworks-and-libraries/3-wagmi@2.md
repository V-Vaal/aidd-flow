# 3 wagmi@2

Hook Patterns:
- Use useReadContract for read operations
- Use useWriteContract for write operations
- Use useWaitForTransactionReceipt for confirmations
- Separate read and write hooks clearly
- Use useAccount for connection state
- Use useChainId for chain validation
- Use useConfig for wagmi configuration

Reads vs Writes:
- Never use write hooks for read operations
- Use read hooks for all data fetching
- Use write hooks only for transaction initiation
- Keep read and write logic separate
- Use separate hooks for different operations
- Avoid mixing read and write in same hook

Chain and Transport Configuration:
- Configure transports explicitly
- Use appropriate RPC endpoints per chain
- Handle chain switching gracefully
- Validate chain support before operations
- Use chain-specific configurations
- Handle transport failures explicitly
- Configure fallback transports

Loading and Error States:
- Always handle loading states
- Always handle error states
- Show loading indicators during operations
- Display error messages to users
- Never ignore hook errors
- Handle undefined data states
- Provide fallback UI for errors

Cache and Refetch Rules:
- Use refetchInterval for time-sensitive data
- Avoid excessive refetch calls
- Use enabled flag to control fetching
- Prevent refetch storms with debouncing
- Cache read results appropriately
- Invalidate cache after writes
- Use staleTime to control freshness

Avoiding Refetch Storms:
- Debounce refetch triggers
- Use refetchInterval sparingly
- Avoid refetching on every render
- Use enabled conditions to prevent unnecessary fetches
- Batch related refetch calls
- Monitor refetch frequency
- Use refetchOnWindowFocus selectively

Wallet Not Connected:
- Check connection status before operations
- Show connect prompt when not connected
- Handle disconnected state gracefully
- Never assume wallet is connected
- Validate account presence before reads
- Provide clear connection instructions
- Handle connection rejection

Wrong Network:
- Validate chain ID before operations
- Show network switch prompt when needed
- Handle network mismatch errors
- Provide clear network requirements
- Use useSwitchChain for network switching
- Handle switch rejection gracefully
- Display current and required networks

User Rejects Signature:
- Handle user rejection explicitly
- Never treat rejection as error
- Show user-friendly rejection message
- Allow user to retry after rejection
- Don't persist rejection state
- Handle rejection in transaction flows
- Provide alternative actions

RPC Errors:
- Handle RPC errors separately from user errors
- Distinguish network errors from user errors
- Retry transient RPC errors
- Show appropriate error messages
- Handle rate limiting errors
- Handle timeout errors explicitly
- Provide fallback for RPC failures

Transaction Handling:
- Use useWaitForTransactionReceipt for confirmations
- Handle pending transaction states
- Show transaction status to users
- Handle transaction failures
- Verify transaction success on-chain
- Never assume transaction succeeded from hook
- Poll for final confirmation
- Do not assume `isSuccess` implies finality; always confirm on-chain state
