{extends file='parent:frontend/index/index.tpl'}

{block name="frontend_index_header_javascript_tracking"}
    {$smarty.block.parent}

    <script async>
        var _paq = _paq || [];

        {* ----- TRACKING DETAIL ----- *}
        {if $Controller == "detail"}
            _paq.push([
                'setEcommerceView',
                '{$sArticle.ordernumber}',
                '{$sArticle.articleName|escape:'javascript'}',
                '{$sCategoryInfo.name|escape:'javascript'}'
            ]);
        {/if}

        {* ----- TRACKING CATEGORY ----- *}
        {if $Controller == "listing"}
            _paq.push([
                'setEcommerceView',
                false,
                false,
                '{$sCategoryContent.name|escape:'javascript'}'
            ]);
        {/if}

        {if {config name='ecommerce' namespace='TinectMatomo'}}
            {* ----- TRACKING ORDERS WITH ARTICLES ----- *}
            {if $sBasket.content}

                {if $sAmountWithTax}
                    {assign var="grandTotal" value=$sAmountWithTax|replace:",":"."}
                {else}
                    {assign var="grandTotal" value=$sAmount|replace:",":"."}
                {/if}

                {if $sAmountNet}
                    {assign var="sAmountNumeric" value=$sAmountNet|replace:",":"."}
                {else}
                    {assign var="sAmountNumeric" value=$sAmount|replace:",":"."}
                {/if}

                {assign var="tax" value=$grandTotal-$sAmountNumeric}
                {assign var="shipping" value=$sShippingcosts|replace:",":"."}
                {assign var="subTotal" value=$grandTotal-$shipping}

                {assign var="orderpositions" value=[]}

                {*
                This is a fix to manage duplicated ordernumbers in one order - used f.e. in many B2B-Shops
                It will be combined into one product!
                *}
                {foreach $sBasket.content as $sBasketItem}

                    {assign var="ordernumber" value={$sBasketItem.ordernumber|escape:'javascript'}}

                    {if $orderpositions[{$ordernumber}].qty > 0}
                        {assign var="newqty" value=($orderpositions[{$ordernumber}].qty + $sBasketItem.quantity)}

                        {$orderpositions[{$ordernumber}].price =
                            (
                                ($orderpositions[{$ordernumber}].qty * $orderpositions[{$ordernumber}].price)
                                +
                                ($sBasketItem.priceNumeric * $sBasketItem.quantity)
                            ) / $newqty
                        }
                        {$orderpositions[{$ordernumber}].qty = $newqty}
                    {else}
                        {$orderpositions[{$ordernumber}] =
                            [
                                'name' => {$sBasketItem.articlename|escape:'javascript'},
                                'price' => {$sBasketItem.priceNumeric|round:2},
                                'qty' => {$sBasketItem.quantity}
                            ]
                        }
                    {/if}
                {/foreach}

                {foreach $orderpositions as $k=>$item}

                    _paq.push([
                        'addEcommerceItem',
                        '{$k}',
                        '{$item.name}',
                        ' ',
                        '{$item.price|round:2}',
                        '{$item.qty}'
                    ]);

                {/foreach}

                {if {config name='justecommercenet' namespace='TinectMatomo'}}
                    {$grandTotal = $grandTotal - $tax}
                    {$subTotal = $subTotal - $tax}
                    {$tax = 0}
                {/if}

                {if $sOrderNumber}
                    _paq.push([
                        'trackEcommerceOrder',
                        '{$sOrderNumber}',
                        '{$grandTotal|round:2}',
                        '{$subTotal|round:2}',
                        '{$tax|round:2}',
                        '{$sShippingcosts|replace:',':'.'|round:2}',
                        false
                    ]);
                {else}
                    _paq.push([
                        'trackEcommerceCartUpdate',
                        '{$grandTotal|round:2}'
                    ]);
                {/if}
            {/if} //sBasket.content
        {/if} //ecommerce

        {block name="frontend_tinectmatomno_paq"}
            {* Use this block to push data to _paq *}
        {/block}

        _paq.push(['trackPageView']);
        _paq.push(['enableLinkTracking']);

        _paq.push(['setTrackerUrl', '{config name='matomopath' namespace='TinectMatomo'}/{config name='phppath' namespace='TinectMatomo'}']);
        _paq.push(['setSiteId', '{config name='siteid' namespace='TinectMatomo'}']);

        {if !{config name='compilejs' namespace='TinectMatomo'}}
            (function () {
                var d = document, g = d.createElement('script'), s = d.getElementsByTagName('script')[0];
                g.type = 'text/javascript';
                g.async = true;
                g.defer = true;
                g.src = '{config name='matomopath' namespace='TinectMatomo'}/{config name='jspath' namespace='TinectMatomo'}';
                s.parentNode.insertBefore(g, s);
            })();
        {/if}
    </script>
{/block}
