{block name="backend/base/header/css"}
    {$smarty.block.parent}
   <style>
       .sprite-matomo {
           background-image: url("../custom/plugins/TinectMatomo/plugin.png");
       }
   </style>
{/block}

{block name="backend/base/header/javascript"}
    {$smarty.block.parent}
    <script>

        function openMatomo() {
            window.open("{$MatomoPath}",'matomo');
        }

    </script>
{/block}