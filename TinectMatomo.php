<?php

namespace TinectMatomo;

use Doctrine\Common\Collections\ArrayCollection;
use Shopware\Components\Plugin;
use Shopware\Components\Plugin\Context\ActivateContext;
use Shopware\Components\Plugin\Context\InstallContext;
use Shopware\Components\Plugin\Context\UpdateContext;

class TinectMatomo extends Plugin
{

    public function activate(ActivateContext $context)
    {
        $context->scheduleClearCache(InstallContext::CACHE_LIST_ALL);
    }

    public function update(UpdateContext $context)
    {
        $context->scheduleClearCache(InstallContext::CACHE_LIST_ALL);
    }

    public function install(InstallContext $context)
    {
    }

    public static function getSubscribedEvents()
    {
        return [
            'Enlight_Controller_Action_PostDispatchSecure_Frontend' => 'onFrontendDispatch',
            'Theme_Compiler_Collect_Plugin_Javascript' => 'onCollectJavascriptFiles'
        ];
    }

    public function onCollectJavascriptFiles(\Enlight_Event_EventArgs $args)
    {
        $config = $this->container->get('shopware.plugin.config_reader')->getByPluginName(
            $this->getName(),
            $args->get('shop')
        );

        if ($config['compilejs']) {
            $jsPath = $this->container->get('kernel')->getCacheDir() . '/' . 'matomo.js';

            file_put_contents(
                $jsPath,
                file_get_contents($config['matomopath'] . '/' . $config['jspath'])
            );

            return new ArrayCollection(array(
                $jsPath
            ));
        }

        return null;
    }

    public function onFrontendDispatch(\Enlight_Controller_ActionEventArgs $args)
    {
        $subject = $args->getSubject();

        $subject->View()->addTemplateDir($this->getPath() . '/Resources/Views/');
    }
}
