use plctag::AsyncTag;
use plctag::log::{DebugLevel, set_debug_level};

const PLC_ADDRESS: &str = "PLC_IP_ADDRESS:44818";
const PLC_TYPE: &str = "PLC_TYPE";
const PLC_TAG: &str = "TAG_NAME";

#[tokio::main]
async fn main() {
    let plc_tag = format!(
        "protocol=ab-eip&plc={}&gateway={}&name={}&elem_count=1&elem_size=1",
        PLC_TYPE, PLC_ADDRESS, PLC_TAG
    );
    set_debug_level(DebugLevel::Detail);
    let mut async_tag = AsyncTag::new(plc_tag).unwrap();
    tokio::time::sleep(std::time::Duration::from_secs(2)).await;

    async_tag.write().await.unwrap();
    async_tag.read().await.unwrap();
}
