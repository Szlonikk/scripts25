player.onChat("s", function () {
    blocks.fill(
    STONE_BRICK_MONSTER_EGG,
    pos(-10, -2, -10),
    pos(10, 10, 10),
    FillOperation.Outline
    )
    blocks.fill(
    PLANKS_OAK,
    pos(-10, -1, -10),
    pos(10, -2, 10),
    FillOperation.Replace
    )
    blocks.fill(
    COBBLESTONE_MONSTER_EGG,
    pos(-11, 0, 1),
    pos(-13, 5, 5),
    FillOperation.Outline
    )
    blocks.fill(
    AIR,
    pos(-10, 0, 2),
    pos(-13, 3, 4),
    FillOperation.Replace
    )
    blocks.fill(
    STONE_MONSTER_EGG,
    pos(-12, 0, -12),
    pos(-8, 15, -8),
    FillOperation.Replace
    )
    blocks.fill(
    STONE_MONSTER_EGG,
    pos(12, 0, 12),
    pos(8, 15, 8),
    FillOperation.Replace
    )
    blocks.fill(
    STONE_MONSTER_EGG,
    pos(-12, 0, 12),
    pos(-8, 15, 8),
    FillOperation.Replace
    )
    blocks.fill(
    STONE_MONSTER_EGG,
    pos(12, 0, -12),
    pos(8, 15, -8),
    FillOperation.Replace
    )
    blocks.place(TORCH, pos(-9, 3, 0))
    blocks.place(TORCH, pos(-9, 3, 5))
    blocks.place(TORCH, pos(9, 3, -5))
    blocks.place(TORCH, pos(9, 3, 5))
})
