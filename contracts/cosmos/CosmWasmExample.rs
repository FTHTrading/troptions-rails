// Cosmos IBC Hub CosmWasm example (Rust).
// Real starter for oracle consumer / IBC coordination.

use cosmwasm_std::{entry_point, DepsMut, Env, MessageInfo, Response, StdResult};
use cosmwasm_std::coins;

#[entry_point]
pub fn execute(
    deps: DepsMut,
    _env: Env,
    info: MessageInfo,
    msg: ExecuteMsg,
) -> StdResult<Response> {
    match msg {
        ExecuteMsg::ReceiveStable { amount, denom } => {
            // Stablecoin integration: USDC etc. via IBC
            let msg = BankMsg::Send {
                to_address: info.sender.to_string(),
                amount: coins(amount, denom),
            };
            Ok(Response::new().add_message(msg))
        }
    }
}

#[derive(Serialize, Deserialize, Clone, Debug, PartialEq, JsonSchema)]
pub enum ExecuteMsg {
    ReceiveStable { amount: u128, denom: String },
}
