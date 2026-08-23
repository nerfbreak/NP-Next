from arq import create_pool
from arq.connections import RedisSettings

async def inventory_adjustment(ctx, run_id: str) -> None:
    # Implementation comes after legacy behavior is inspected and tests exist.
    raise NotImplementedError(run_id)

class WorkerSettings:
    functions = [inventory_adjustment]
    redis_settings = RedisSettings()

async def main() -> None:
    await create_pool(WorkerSettings.redis_settings)
