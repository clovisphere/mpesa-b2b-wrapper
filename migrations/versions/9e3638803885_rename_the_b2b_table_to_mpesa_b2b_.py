"""Rename the 'b2b' table to 'mpesa_b2b_transactions'.

Revision ID: 9e3638803885
Revises: 
Create Date: 2023-05-04 03:26:57.406536

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '9e3638803885'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('mpesa_b2b_transactions',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('amount', sa.Integer(), nullable=True),
    sa.Column('pnr', sa.String(length=100), nullable=False),
    sa.Column('originator_conversation_id', sa.String(length=100), nullable=False),
    sa.Column('conversation_id', sa.String(length=100), nullable=False),
    sa.Column('status', sa.Enum('PENDING', 'SUCCESS', 'FAILED', name='statusenum'), nullable=True),
    sa.Column('created_on', sa.DateTime(), server_default=sa.text('(CURRENT_TIMESTAMP)'), nullable=False),
    sa.Column('updated_on', sa.DateTime(), server_default=sa.text('(CURRENT_TIMESTAMP)'), nullable=False),
    sa.PrimaryKeyConstraint('id'),
    sa.UniqueConstraint('conversation_id'),
    sa.UniqueConstraint('originator_conversation_id')
    )
    with op.batch_alter_table('mpesa_b2b_transactions', schema=None) as batch_op:
        batch_op.create_index(batch_op.f('ix_mpesa_b2b_transactions_created_on'), ['created_on'], unique=False)
        batch_op.create_index(batch_op.f('ix_mpesa_b2b_transactions_pnr'), ['pnr'], unique=True)

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('mpesa_b2b_transactions', schema=None) as batch_op:
        batch_op.drop_index(batch_op.f('ix_mpesa_b2b_transactions_pnr'))
        batch_op.drop_index(batch_op.f('ix_mpesa_b2b_transactions_created_on'))

    op.drop_table('mpesa_b2b_transactions')
    # ### end Alembic commands ###
