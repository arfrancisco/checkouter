class OrdersController < ApplicationController
  def index
    @products = Product.all
    @order = Order.find_by(name: params[:customer_name])
    @total = ::CheckoutFlow.system_calculates_order_total(customer_name: @order.name)
  end

  def new
    @products = Product.all
    @order = Order.new
  end

  def create
    @products = Product.all
    @order = Order.new(name: params[:order][:name])

    if @order.save
      redirect_to orders_path(customer_name: @order.name)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def add_product
    ::CheckoutFlow.customer_adds_product_to_order(customer_name: params[:customer_name], product_id: params[:id])

    redirect_to orders_path(customer_name: params[:customer_name])
  end

  def remove_product
    ::CheckoutFlow.customer_removes_product_from_order(customer_name: params[:customer_name], product_id: params[:id])

    redirect_to orders_path(customer_name: params[:customer_name])
  end
end
